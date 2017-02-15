#!/bin/bash

echo "# docker stop rpi-iroha-build"
docker stop rpi-iroha-build

echo "# docker rm rpi-iroha-build"
docker rm rpi-iroha-build

echo "# docker run -it --name rpi-iroha-build -v $(pwd)/opt/iroha:/opt/iroha tkyonezu/rpi-iroha-build /bin/bash"
docker run -it --name rpi-iroha-build -v $(pwd)/opt/iroha:/opt/iroha tkyonezu/rpi-iroha-build /bin/bash
