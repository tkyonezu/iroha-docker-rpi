#!/bin/bash

#
# Check Docker capability
#
if [ $(id -u) -ne 0 ]; then
  if ! id -Gn | grep -q docker 2>/dev/null; then
    echo "*ERROR* You don't have Docker capability."
    exit 1
  fi
fi

#
# Check OS type
#
case $(uname -s) in
  Darwin) OS="Mac";;
  Linux) if [ "$(uname -m)" = "armv7l" ]
      then  OS="rpi";
      else  OS="Linux"
    fi;;
  *) echo "*ERROR* This machine does'nt supported."
    exit 1;;
esac

#
# Globa Parameters
#
VENDOR="tkyonezu"

IH_UID=168
IH_GID=168

IROHA_HOME="/opt/iroha"

IH_NET="iroha_net"
IH_SUBNET="10.0.168.0/24"

if [ "$OS" = "rpi" ]; then
  IH_NAME="rpi-iroha-build"
  IH_NODES=3
else
  if [ $# -eq 0 ]; then
    IH_NAME="iroha"
  else
    IH_NAME="$1"
  fi

  IH_NODES=4
fi

if [ "$OS" == "Mac" ]; then
  IH_HOME="${HOME}/iroha"
else
  IH_HOME="${IROHA_HOME}"
fi

#
# Check IROHA configuration files
#
if [ ! -d ${IH_HOME}/config ]; then
  echo "*ERROR* IROHA config directory missing on ${IH_HOME}"
  exit 1
fi

NO=1
while [ ${NO} -le ${IH_NODES} ]; do
  cd ${IH_HOME}/config
  if [ ! -e config${NO}/sumeragi.json ]; then
    echo "*ERROR* IROHA config file missing ${IH_HOME}/config/config${NO}/sumeragi.json"
    exit 1
  fi
  ((NO+=1))
done

#
# Check and Make IROHA ledger directories
#
if [ ! -d ${IH_HOME}/ledger ]; then
  echo "# mkdir ${IH_HOME}/ledger"
  mkdir ${IH_HOME}/ledger
  if [ $? -ne 0 ]; then
    echo "*ERROR* You don't have permission to mkdir on (${IH_HOME}/ledger)."
    exit 1
  fi

  if [ "$OS" != "Mac" ]; then
    echo "# chown ${IH_UID}:${IH_GID} ${IH_HOME}/ledger"
    chown ${IH_UID}:${IH_GID} ${IH_HOME}/ledger
  fi

  echo "# cd ${IH_HOME}/ledger"
  cd ${IH_HOME}/ledger

  NO=1
  while [ ${NO} -le ${IH_NODES} ]; do
    echo "# mkdir iroha_ledger${NO}"
    mkdir iroha_ledger${NO}

    if [ "$OS" != "Mac" ]; then
      echo "# chown ${IH_UID}:${IH_GID} iroha_ledger${NO}"
      chown ${IH_UID}:${IH_GID} iroha_ledger${NO}

      echo "# chmod 0700 iroha_ledger${NO}"
      chmod 0700 iroha_ledger${NO}
    fi

    ((NO+=1))
  done
fi

#
# Check and Create IROHA network for Docker
#
NET_ID=$(docker network list --filter NAME=${IH_NET} -q)

if [ "${NET_ID}" == "" ]; then
  docker network create --subnet=${IH_SUBNET} ${IH_NET}
else
  if [ "$OS" == "Linux" ]; then
    SUBNET=$(ip route | grep ${NET_ID} | cut -d' ' -f1)

    if [ "$IH_SUBNET" != "$SUBNET" ]; then
      echo "*ERROR* \"${IH_NET}\" subnet value different from \"${IH_SUBNET}\"."
      ip route | grep ${NET_ID}
      echo
      echo "Run 'docker network rm'  command to remove docker network."

      exit 1
    fi
  fi
fi

echo "### Current (iroha_net) Netrork Information ###"
echo

docker network list --filter NAME=${IH_NET}

echo

NET_ID=$(docker network list --filter NAME=${IH_NET} -q)

if [ "${NET_ID}" != "" ]; then
  ip route | grep ${NET_ID}
  echo
fi

#
# Docker run IROHA containers
#
NO=1
while [ ${NO} -le ${IH_NODES} ]; do
  IROHA="${IH_NAME}${NO}"

  echo "# docker stop ${IROHA}"
  docker stop ${IROHA}

  echo "# docker rm ${IROHA}"
  docker rm ${IROHA}

  ((n=${NO}+1))
  IH_IP=$(echo "$(echo ${IH_SUBNET} | cut -d'.' -f1-3).$n")

  if [ ${NO} -eq ${IH_NODES} ]; then
    echo "# docker run -d --name ${IROHA} -p 1204:1204 --restart=always -v ${IH_HOME}/config/config${NO}:${IROHA_HOME}/config -v ${IH_HOME}/ledger/iroha_ledger${NO}:/tmp/iroha_ledger --network=${IH_NET} --ip=${IH_IP} ${VENDOR}/${IH_NAME}"

    docker run -d --name ${IROHA} -p 1204:1204 \
      --restart=always \
      -v ${IH_HOME}/config/config${NO}:${IROHA_HOME}/config \
      -v ${IH_HOME}/ledger/iroha_ledger${NO}:/tmp/iroha_ledger \
      --network=${IH_NET} --ip=${IH_IP} \
      ${VENDOR}/${IH_NAME} /bin/su - iroha \
      -c "env IROHA_HOME=${IROHA_HOME} ${IROHA_HOME}/build/bin/iroha-main"
  else
    echo "# docker run -d --name ${IROHA} --restart=always -v ${IH_HOME}/config/config${NO}:${IROHA_HOME}/config -v ${IH_HOME}/ledger/iroha_ledger${NO}:/tmp/iroha_ledger --network=${IH_NET} --ip=${IH_IP} ${VENDOR}/${IH_NAME}"

    docker run -d --name ${IROHA} \
      --restart=always \
      -v ${IH_HOME}/config/config${NO}:${IROHA_HOME}/config \
      -v ${IH_HOME}/ledger/iroha_ledger${NO}:/tmp/iroha_ledger \
      --network=${IH_NET} --ip=${IH_IP} \
      ${VENDOR}/${IH_NAME} /bin/su - iroha \
      -c "env IROHA_HOME=${IROHA_HOME} ${IROHA_HOME}/build/bin/iroha-main"
  fi

  ((NO+=1))
done

exit 0
