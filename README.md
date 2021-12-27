# How to setup QGIS Web 2 (client) and QGIS Server

> Note the authoritative source for information on QGIS is the official project (see https://github.com/qwc-services/ and https://github.com/qgis/)

> In fact, the official documentation will probably be better: https://qwc.sourcepole.com/quick-start/ we **strongly advise you follow the official quickstart**

QGIS requires both a client and server.

There are two well-known clients: 

1. A desktop version which must be installed like a traditional application.
2. A web based client, the most recent one being a modern 'react' based one.

There is one QGIS server implementation (implementing [web map service](https://en.wikipedia.org/wiki/Web_Map_Service) and [Web Feature Services (WFS)](https://en.wikipedia.org/wiki/Web_Feature_Service).

## Install
Run once
```
./install.sh
```

## Run

```
./run.sh
```

## Visit web client

http://localhost:8088/

# Errors


## RuntimeError The session is unavailable because no secret key was set
```
qwc-auth-service_1             | RuntimeError: The session is unavailable because no secret key was set.  Set the secret_key on the application to something unique and secret.
```

Fix: You are probably missing `JWT_SECRET_KEY` in your `.env` file inside `qwc-docker` folder.

To generate one:
```
python3 -c 'import secrets; print("JWT_SECRET_KEY=\"%s\"" % secrets.token_hex(48))' >>.env
```
