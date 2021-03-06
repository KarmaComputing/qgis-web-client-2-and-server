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

# Errors & how to fix

## Invalid username or password (when accessing http://localhost:8088/auth/login)

> If you're developing locally, you can reset the volumes and *delete* 
  all persistant data, this will allow you reset the password.

Using `docker-compose down --volumes`
Then visit http://localhost:8088/qwc_admin/ and you'll be able to start-over

Full example reset password (and delete all persistant data)
```
cd /path/to/your/project (e.g /home/fred/qgis-web-client-2-and-server/qwc-services/qwc-docker(
(base) (master)$ docker-compose down --volumes 
Removing qwc-docker_qwc-api-gateway_1             ... done
Removing qwc-docker_qwc-mapinfo-service_1         ... done
Removing qwc-docker_qwc-auth-service_1            ... done
Removing qwc-docker_qwc-data-service_1            ... done
Removing qwc-docker_qwc-ogc-service_1             ... done
Removing qwc-docker_qwc-fulltext-search-service_1 ... done
Removing qwc-docker_qwc-admin-gui_1               ... done
Removing qwc-docker_qwc-permalink-service_1       ... done
Removing qwc-docker_qwc-map-viewer_1              ... done
Removing qwc-docker_qwc-config-service_1          ... done
Removing qwc-docker_qwc-solr_1                    ... done
Removing qwc-docker_qwc-qgis-server_1             ... done
Removing qwc-docker_qwc-elevation-service_1       ... done
Removing qwc-docker_qwc-postgis_1                 ... done
Removing network qwc-docker_default
```


## RuntimeError The session is unavailable because no secret key was set
```
qwc-auth-service_1             | RuntimeError: The session is unavailable because no secret key was set.  Set the secret_key on the application to something unique and secret.
```

Fix: You are probably missing `JWT_SECRET_KEY` in your `.env` file inside `qwc-docker` folder.

To generate one:
```
python3 -c 'import secrets; print("JWT_SECRET_KEY=\"%s\"" % secrets.token_hex(48))' >>.env
```

# FAQ

## Why is my qgs map not showing after I copied it into `./qwc-docker/volumes/config-in/default/qgis_projects`?

Scenario: I follow the steps to [Add a QGIS project](https://qwc.sourcepole.com/quick-start/#add-a-qgis-project) but when I go to http://localhost:8088/, I don't see the new project.


1. Generate new Service configuration: http://localhost:8088/qwc_admin/
2. Go to Resources -> and click 'Import maps' (http://localhost:8088/qwc_admin/resources), then you'll see `natural-earth-countries` in the list (if that's what you've imported)
3. Still on `Resources` page, click `Edit` (next to the new map) then `Import layers` (takes long time) see below if error observed:

Error observed:
```
qwc-api-gateway_1              | 172.23.0.1 - - [27/Dec/2021:21:46:38 +0000] "POST /qwc_admin/resources/5/import_children HTTP/1.1" 504 494 "http://localhost:8088/qwc_admin/resources/5/edit" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36" "-"
qwc-config-service_1           | [2021-12-27 21:46:39,312] CRITICAL in config_generator: Could not get GetProjectSettings from http://qwc-qgis-server/ows/qwc_demo:
```

Fix:

> Make sure you have updated `pg_service.conf` to include `qwc_geodb` for localhost access.
  TODO: Understand if/why both are needed


`pg_service.conf` example:
```
...removed to save space...

[qwc_geodb]
host=qwc-postgis
port=5432
dbname=qwc_demo
user=qwc_service
password=qwc_service
sslmode=disable

...removed to save space...

[qwc_geodb]
host=localhost
port=5439
dbname=qwc_demo
user=qwc_service
password=qwc_service
sslmode=disable
```
Stop/start docker-compose then repeat step 3.


http://localhost:8088/qwc_admin/resources?type=map

## What is Difference between .qgs and .qgz

Not a lot- `qgz` is a zipped `qgz`
See [Difference between .qgs and .qgz](https://gis.stackexchange.com/questions/333489/difference-between-qgs-and-qgz) for detail.

## ERROR in config_generator: ERROR generating thumbnail for WMS qwc_demo

When pressing the green "Generate service configuration" button in http://localhost:8088/qwc_admin/
the following error is seen:

```
qwc-config-service_1           | [2021-12-27 19:22:02,970] ERROR in config_generator: ERROR generating thumbnail for WMS qwc_demo:
qwc-config-service_1           | [Errno 13] Permission denied: '/qwc2//assets/img/genmapthumbs/qwc_demo.png'
```
Relating (probably) to [qwc-config-service](https://github.com/qwc-services/qwc-config-service), which is
called in `build-services.sh` during docker-compose up.

Fix: ?
