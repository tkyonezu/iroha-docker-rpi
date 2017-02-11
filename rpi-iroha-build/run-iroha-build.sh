#!/bin/bash

echo "# docker stop rpi-iroha-build"
docker stop rpi-iroha-build

echo "# docker rm rpi-iroha-build"
docker rm rpi-iroha-build

echo "# docker run --name rpi-iroha-build -v /opt/iroha:/opt/iroha -it tkyonezu/rpi-iroha-build /bin/bash"
docker run --name rpi-iroha-build -v /opt/iroha:/opt/iroha -v$(pwd)/var/tmp:/var/tmp -it tkyonezu/rpi-iroha-build /bin/bash
