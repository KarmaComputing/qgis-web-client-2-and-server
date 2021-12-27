#!/bin/bash

# These steps are from:
# https://github.com/qwc-services/qwc-services-core#quick-start
mkdir qwc-services
cd qwc-services/

git clone https://github.com/qwc-services/qwc-docker.git
cd qwc-docker/
cp docker-compose-example.yml docker-compose.yml

python3 -c 'import secrets; print("JWT_SECRET_KEY=\"%s\"" % secrets.token_hex(48))' >.env

