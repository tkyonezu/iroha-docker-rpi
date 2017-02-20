#-----------------------------------------------------------------------
# Raspberry Pi 3
#
# rpi-iroha-build - IROHA building container
#
# build : docker build -t tkyonezu/rpi-iroha-build .
#
# Copyright (c) 2016, 2017 Soramitsu,Co.,Ltd.
# All Rights Reserved.
#-----------------------------------------------------------------------
FROM tkyonezu/rpi-iroha-dev

MAINTAINER Takeshi Yonezu <yonezu@soramitsu.co.jp>

ARG BRANCH=${BRANCH:-master}
RUN echo "IROHA clone branch: ${BRANCH}"

LABEL Vendor="Soramitsu,Co.,Ltd." \
      License="Apache License, Version 2.0" \
      Git="git clone -b ${BRANCH} --recursive https://github.com/hyperledger/iroha.git" \
      Build="docker build --build-arg BRANCH=${BRANCH} -t tkyonezu/rpi-iroha-build ." \
      Run="docker run -d --name rpi-iroha-build -p1204:1204 tkyonezu/rpi-iroha-build"

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-armhf
ENV IROHA_HOME /opt/iroha

COPY ./crypto.patch ./64to32.patch /var/tmp/

WORKDIR /opt

RUN git clone -b ${BRANCH} --recursive https://github.com/hyperledger/iroha.git

RUN cd ${IROHA_HOME}/core/vendor/leveldb; make && \
    cd ${IROHA_HOME}/core/vendor/ed25519; make && \
    cd ${IROHA_HOME}/core/vendor/KeccakCodePackage; \
      make; make generic32/libkeccak.a && \
    cd ${IROHA_HOME}; mkdir build; cd build; cmake .. && \
    cd ${IROHA_HOME}; patch -p1 </var/tmp/64to32.patch && \
    sed -i 's/generic64/generic32/' fabfile.py \
      core/infra/crypto/CMakeLists.txt \
      core/validation/CMakeLists.txt \
      docker/dev/scripts/build-iroha.sh \
      docs/how_to_build.rst \
      peer/CMakeLists.txt \
      test/consensus/CMakeLists.txt \
      test/crypto/CMakeLists.txt && \
    sed -i 's/amd64/armhf/' fabfile.py && \
    cd ${IROHA_HOME}; patch -p1 </var/tmp/crypto.patch && \
    cd ${IROHA_HOME}/core/infra/crypto; make && \
    cd ${IROHA_HOME}/build; make

RUN groupadd -g 168 iroha && \
    useradd -g iroha -u 168 -c "IROHA Administrator" -d /opt/iroha iroha && \
    chown iroha:iroha /opt/iroha

WORKDIR ${IROHA_HOME}

CMD ["/bin/su","-","iroha","-c","env IROHA_HOME=${IROHA_HOME} ${IROHA_HOME}/build/bin/iroha-main"]
