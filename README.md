
# QWC Services & QGIS online setup notes

Goal: I have a few QGIS Desktop projects which I want to successfully load/show
on the awesome "QWC2" aka ["QWC / QWC Services" project](https://qwc-services.github.io/master/) so people can see these map projects in the web browser.

You'll find sections

- How to I get the software?
- How do I configure it?
- How do I run it?

## Setup-  How to I get QWC Services software?

Copied from [Quickstart](https://qwc-services.github.io/master/QuickStart/)

```shell
git clone --recursive https://github.com/qwc-services/qwc-docker.git
cd qwc-docker
cp docker-compose-example.yml docker-compose.yml
cp api-gateway/nginx-example.conf api-gateway/nginx.conf
```

## How do I configure it?

## Files of importance

- `./qwc-docker/volumes/config-in/default/themesConfig.json`
  - This is where you state the maps you want to load,
    their title, folder they're stored in, and coordinate system used (CRS)

E.g. Excerpt from `./config-in/default/themesConfig.json`:

```shell
   ...
   "defaultMapCrs": "EPSG:3857", 
   "defaultTheme": "scan/solution",
    "themes": {
        "items": [
           {
                "id": "leazes_park",
                "title": "Leazes Park",
                "url": "/ows/scan/solution/LeazesPark/LeazesPark",
                "mapCrs": "EPSG:27700",
                "backgroundLayers": [{"name": "background_layer_name"}],
                "searchProviders": ["coordinates"]
           },
           {
                "id": "example_two",
                "title": "Example Two",
                "url": "/ows/scan/solution/ExampleMapTwo/ExampleMapTwo",
                "mapCrs": "EPSG:27700",
                "backgroundLayers": [{"name": "background_layer_name"}],
                "searchProviders": ["coordinates"]
           }
        ],
        "backgroundLayers": ...
        ...
```

## `../config/default/mapViewerConfig.json` config

Needs to be stopped/started after edit:

```shell
docker-compose stop qwc-map-viewer
# Edit ../config/default/mapViewerConfig.json
docker-compose start qwc-map-viewer
```

```shell
...
          {                                                                                                                                                                             
            "id": "melvin",                                                                                                                                                              
            "name": "solution/melvinGC/melvinGC",                                                                                                                                         
            "title": "melvin",                                                                                                                                                           
            "description": "",                                                                                                                                                          
            "wmsOnly": false,                                                                                                                                                           
            "wms_name": "scan/solution/melvinGC/melvinGC",                                                                                                                                
            "url": "/ows/scan/solution/melvinGC/melvinGC",                                                                                                                                
            "attribution": {                                                                                                                                                            
              "Title": null,                                                                                                                                                            
              "OnlineResource": null                                                                                                                                                    
            },                                                                                                                                                                          
            "abstract": "",                                                                                                                                                             
            "keywords": "",                                                                                                                                                             
            "onlineResource": "",                                                                                                                                                       
            "contact": {                                                                                                                                                                
              "person": null,                                                                                                                                                           
              "organization": null,                                                                                                                                                     
              "position": null,                                                                                                                                                         
              "phone": null,                                                                                                                                                            
              "email": null                                                                                                                                                             
            },                                                                                                                                                                          
            "mapCrs": "EPSG:27700",                                                                                                                                                     
            "bbox": {                                                                                                                                                                   
              "crs": "EPSG:4326",                                                                                                                                                       
              "bounds": [                                                                                                                                                               
                -3.332358,                                                                                                                                                              
                57.61783,                                                                                                                                                               
                -3.299083,                                                                                                                                                              
                57.635682                                                                                                                                                               
              ]                                                                                                                                                                         
            },
            "initialBbox": {                                                                                                                                                            
              "crs": "EPSG:4326",                                                                                                                                                       
              "bounds": [                                                                                                                                                               
                -3.332358,                                                                                                                                                              
                57.61783,                                                                                                                                                               
                -3.299083,                                                                                                                                                              
                57.635682                                                                                                                                                               
              ]                                                                                                                                                                         
            },
...
```

Get the CRS correct for the map.

## How do I run QWC Services?

```shell
cd qwc-docker/
docker compose up
```

Visit: [http://localhost:8088/auth/login?url=http://localhost:8088/qwc_admin/](http://localhost:8088/auth/login?url=http://localhost:8088/qwc_admin/)

- "What's the username?" `admin` most likely.
- "What's the password"? Good question. Can be set by setting `POSTGRES_PASSWORD` in the `docker-compose.yml` file, service `qwc-postgis` -> `environment` section with a key
of `POSTGRES_PASSWORD` and the value of a password.

## Loading / Generating Maps for the Online web view

> The [Generate service configuration](http://localhost:8088/qwc_admin/) button on the QWC
  Admin panel is lovely, and needed, however, by default it (and can't?) show all the failure logs you **need** to see when loading in new map configurations. To see those (and fix them)

## Errors / solutions

> The [set_permissions.sh](https://github.com/qwc-services/qwc-docker/blob/f1f7103695dbf7af5eaf327f280c79e00cd8221e/scripts/set_permissions.sh#L4) tidy's up permissions setting them to the correct owner/permissions.


# services inside the containers are running as $QWC_UID:$QWC_GID
chown -R $QWC_UID:$QWC_GID ./volumes/config

# solr inside the conainer is running as 8983
chown -R 8983:8983 ./volumes/solr/data ./volumes/solr/configsets

chown $QWC_UID:$QWC_GID ./volumes/demo-data/setup-demo-data-permissions.sh

# services inside the containers are running as $QWC_UID:$QWC_GID
chown -R $QWC_UID:$QWC_GID ./volumes/config
chown -R $QWC_UID:$QWC_GID ./volumes/config-in ./volumes/qwc2 ./volumes/qgs-resources ./volumes/attachments
```

Observed errors on Ubuntu:

```shell
Warning 4: Failed to open /data/<path>/<filename>.shp: Permission denied
```

Error:

```shell
Python Exception: [Errno 13] Permission denied: '/srv/qwc_service/config-out/default/searchConfig.json'
Traceback (most recent call last):
  File "/srv/qwc_service/server.py", line 56, in generate_configs
    generator.write_configs()
  File "/srv/qwc_service/config_generator/config_generator.py", line 405, in write_configs
    copyfile(
  File "/usr/lib/python3.12/shutil.py", line 262, in copyfile
    with open(dst, 'wb') as fdst:
         ^^^^^^^^^^^^^^^
PermissionError: [Errno 13] Permission denied: '/srv/qwc_service/config-out/default/searchConfig.json'

```shell
qwc-services expects it can [write and even create directories](https://github.com/qwc-services/qwc-config-generator/blob/063100e44d35103005a9442b17eb8e905c90d0ac/src/config_generator/config_generator.py#L361) on the fly, so needs permission to do that. Given the mounted volumes and how Docker does that, it's likely
you'll need to `sudo chown -R 8983:8983 ./qwc-docker/volumes` your `volumes` directory, whilst not forgetting to stop/start again your `docker compose up` stack.


Error:

```shell
Python Exception: [Errno 13] Permission denied: '/srv/qwc_service/config-out/default/legendConfig.json'
Traceback (most recent call last):
  File "/srv/qwc_service/server.py", line 56, in generate_configs
    generator.write_configs()
  File "/srv/qwc_service/config_generator/config_generator.py", line 405, in write_configs
    copyfile(
  File "/usr/lib/python3.12/shutil.py", line 262, in copyfile
    with open(dst, 'wb') as fdst:
         ^^^^^^^^^^^^^^^
PermissionError: [Errno 13] Permission denied: '/srv/qwc_service/config-out/default/legendConfig.json'

```

```shell
qwc-config-service-1           | [2025-07-20 18:54:58,251] WARNING in config_generator: Failed to write form for layer edit_lines: [Errno 13] Permission denied: '/qwc2/assets/forms/autogen/qwc_demo_edit_lines.ui'
qwc-config-service-1           | [2025-07-20 18:54:58,252] WARNING in config_generator: Failed to write form for layer edit_points: [Errno 13] Permission denied: '/qwc2/assets/forms/autogen/qwc_demo_edit_points.ui'
qwc-config-service-1           | [2025-07-20 18:54:58,254] WARNING in config_generator: Failed to write form for layer edit_polygons: [Errno 13] Permission denied: '/qwc2/assets/forms/autogen/qwc_demo_edit_polygons.ui'
```

Error:

```shell
Unable to load the theme "melvinGC": the projection EPSG:27700 is not defined.
```

Answer:

What the docs don't show easily is you need to edit/add to the list of `projections` in `qwc-docker/volumes/config/default/mapViewerConfig.json`,
for example, to add support in the map viewer for EPSG:27700, you'd add:

```shell
        "projections": [                                                                                                                                                               
          {                                                                                                                                                                            
            "code": "EPSG:27700",                                                                                                                                                      
            "proj": "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs",
            "label": "OSGB 1936 / British National Grid"                                                                                                                               
          },
```

(There's a website [https://epsg.io/](https://epsg.io/) which lists all these seemingly random looking CRSs in a big open database <3 the project has an interesting history!)

> Below are old / outdated notes left for reference.

<strike>

## How to setup QGIS Web 2 (client) and QGIS Server (old)

> Note the authoritative source for information on QGIS is the official project (see [https://github.com/qwc-services/](https://github.com/qwc-services/) and [https://github.com/qgis/](https://github.com/qgis/))

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
</strike>
