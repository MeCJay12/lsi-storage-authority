# Dockerized LSI Storage Authority
LSI Storage Authority (LSA) is the successor to MegaRaid Storage Manager (MSM) for managing MegaRAID cards from inside the OS. LSA improves on MSM by including a web server instead of the old MSM java client that was run locally. LSA features both local and remote server management from one interface.

## Using the Container
### Docker Run

```
docker run \
	--detach \
	--privileged \
	--volume /DataDir:/opt/lsi/LSIStorageAuthority \
	--publish 2463:2463 \
	--publish 9000:9000 \
	--env TZ=America/New_York \
	--env ROOT_PASSWORD="password" \
	--env ADD_USERS_RW="readWriteUser:password user2:password" \
	--env ADD_USERS_RO="readOnlyUser:password" \
	--env WEB_PORT=2463 \
	--env LSA_PORT=9000 \
	mecjay12/lsa
```

### Docker Compose

```
version: "3.3"
services:
  lsa:
    privileged: true
    volumes:
      - /mnt/Docker/LSA:/opt/lsi/LSIStorageAuthority
    ports:
      - 2463:2463
      - 9000:9000
    environment:
      - TZ=America/New_York
      - ROOT_PASSWORD=password
      - ADD_USERS_RW=readWriteUser:password user2:password
      - ADD_USERS_RO=readOnlyUser:password
      - WEB_PORT=2463
      - LSA_PORT=9000
    image: mecjay12/lsa
```

### Command Reference

| Docker Run | Docker Compose | Required On* | Effect |
| ---------- | -------------- | ------------ | ------ |
| --detach | - | All | Run the container in the background |
| --privileged | privileged: true |  Client | Required on the host with the RAID card. Grants the container access to hardware PCI devices. If there is a more specific way to do this (like with --device) please let me know in an issue. |
| --volume <Storage_Path>:/opt/lsi/LSIStorageAuthority | volumes: | Server | Mount the server files to make the configuration persistant. |
| --publish 2463:2463 | ports:<br>- 2464:2463 | Server | Opens the port for the web interface. The default is 2463. This should match WEB_PORT if it is set. |
| --publish 9000:9000 | ports:<br>- 9000:9000 | Client | Opens the port for remote management. The default port is 9000. This should match LSA_PORT on the client if it is set. |
| --env TZ=America/New_York | environment:<br>- TZ=America/New_York | Not | Sets timezone inside the container. |
| --env ROOT_PASSWORD="password" | environment:<br>- ROOT_PASSWORD=password | Not | Sets the password for the root user to login to the web interface. |
| --env ADD_USERS_RW=<br>"readWriteUser:password user2:password" | environment:<br>- ADD_USERS_RW=<br>readWriteUser:password user2:password | Not | Creates additional users with read/write permission in the web interface. Users should be in <username>:<password> format with spaces between multiple users. |
| --env ADD_USERS_RO=<br>"readOnlyUser:password" | environment:<br>- ADD_USERS_RO=<br>readOnlyUser:password | Not | Creates additional users with read-only permission in the web interface. Users should be in <username>:<password> format with spaces between multiple users. |
| --env WEB_PORT=2463 | environment:<br>- WEB_PORT=2463 | Not | Set the port for the web interface. Defaults to 2463 if not set. |
| --env LSA_PORT=9000 | environment:<br>- LSA_PORT=9000 | Not | Set the port for remote management. Defaults to 9000 if not set. |
| mecjay12/lsa | image: mecjay12/lsa | All | Pulls the latest stable version of this container. |

* Client refers to the machine with the RAID card, Server refers to the machine hosting the web interface. A single machine can be both.

## Links

[Docker Hub](https://hub.docker.com/repository/docker/mecjay12/lsa/general)

[GitHub](https://github.com/MeCJay12/lsi-storage-authority/)
