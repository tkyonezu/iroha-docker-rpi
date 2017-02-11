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

USER root

ARG BRANCH=${BRANCH:-master}
RUN echo "IROHA clone branch: ${BRANCH}"

LABEL GIT="git clone -b ${BRANCH} --recursive https://github.com/hyperledger/iroha.git iroha"
LABEL BUILD="docker build --build-arg BRANCH=${BRANCH} -t tkyonezu/rpi-iroha-build ."
LABEL RUN="docker run -d --name iroha tkyonezu/rpi-iroha-build"

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-armhf
ENV IROHA_HOME /opt/iroha

WORKDIR /opt
RUN git clone -b ${BRANCH} --recursive https://github.com/hyperledger/iroha.git

WORKDIR $IROHA_HOME/core/vendor/leveldb
RUN make
WORKDIR $IROHA_HOME/core/vendor/ed25519
RUN make
WORKDIR $IROHA_HOME/core/vendor/KeccakCodePackage
RUN make && make generic32/libkeccak.a

RUN apt -y install vim bash-completion && \
    chmod +x /etc/profile.d/bash_completion.sh

## WORKDIR $IROHA_HOME/core/infra/crypto
## RUN make
## 
## RUN mkdir $IROHA_HOME/build
## WORKDIR $IROHA_HOME/build
## RUN cmake ..
## RUN make

## COPY ./tools/test.sh ./tools/mkiroha-tar.sh ./tools/iroha-out.sh ${IROHA_HOME}/

## USER iroha
WORKDIR $IROHA_HOME

RUN groupadd -g 168 iroha && \
    useradd -g iroha -u 168 -c "IROHA Administrator" -d /opt/iroha iroha && \
    chown iroha:iroha /opt/iroha

CMD ["/bin/su","-","iroha","-c","env IROHA_HOME=${IROHA_HOME} ${IROHA_HOME}/build/bin/iroha-main"]
