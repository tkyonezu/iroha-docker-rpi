#-----------------------------------------------------------------------
# Raspberry Pi 3
#
# rpi-iroha-dev - IROHA Development container
#
# build : docker build -t tkyonezu/rpi-iroha-dev .
#
# Copyright (c) 2016, 2017 Soramitsu,Co.,Ltd.
# All Rights Reserved.
#-----------------------------------------------------------------------
FROM armhf/debian

MAINTAINER Takeshi Yonezu <yonezu@soramitsu.co.jp>

USER root

LABEL BUILD="docker build -t tkyonezu/rpi-iroha-dev ."
LABEL RUN="docker run -it --name rpi-iroha-dev tkyonezu/rpi-iroha-dev /bin/bash"

#
# Upgrade Debian
#
RUN sed -i 's/jessie/stretch/' /etc/apt/sources.list && \
    apt-get update && apt -y upgrade && \
    apt -y install g++-6 gcc-6 default-jdk && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 20 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-6 20 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 20 && \
    update-alternatives --install /usr/bin/cc  cc  /usr/bin/gcc-6 20 && \
    apt -y install curl git make cmake libhdf5-serial-dev libleveldb-dev \
      libsnappy-dev liblmdb-dev libssl-dev unzip xsltproc zlib1g-dev \
      autoconf automake libtool pkg-config software-properties-common \
      vim bash-completion && \
    chmod +x /etc/profile.d/bash_completion.sh

#
# Build protobuf
#

WORKDIR /var/tmp

RUN git clone -b v3.0.0 https://github.com/google/protobuf.git && \
    cd /tmp/protobuf && \
    (git cherry-pick 1760feb621a913189b90fe8595fffb74bce84598; echo Force continue) && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make -j 14 && \
    make install

#
# Build grpc
#

# Does not compile with OpenSSL 1.1.0 #8801 2016/11/20
# https://github.com/grpc/grpc/issues/8801
COPY ./grpc.patch /var/tmp

RUN git clone --recursive -b $(curl -L http://grpc.io/release) https://github.com/grpc/grpc.git && \
    cd grpc && \
    cat //var/tmp/grpc.patch | patch -u -p1 && \
    make && \
    make install

CMD ["/bin/bash"]
