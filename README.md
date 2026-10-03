# Dockerized LSI Storage Authority
LSI Storage Authority (LSA) is the successor to MegaRaid Storage Manager (MSM) for managing MegaRAID cards from inside the OS. LSA improves on MSM by including a web server instead of the old MSM java client that was run locally. LSA features both local and remote server management from one interface.

## Using the Container
### Docker Run

```
docker run \
	--detach \
	--cap-add SYS_ADMIN \
	--volume /DataDir:/opt/lsi/LSIStorageAuthority/conf \
	--volume /LogsDir:/opt/lsi/LSIStorageAuthority/logs \
	--publish 2463:2463 \
	--publish 9000:9000 \
	--env TZ=America/New_York \
	--env ROOT_PASSWORD="password" \
	--env ADD_USERS_RW="readWriteUser:password user2:password" \
	--env ADD_USERS_RO="readOnlyUser:password" \
    --device /dev/mpt2ctl:/dev/mpt2ctl \									# Older devices in IT mode
    --device /dev/mpt3ctl:/dev/mpt3ctl \									# Newer devices in IT mode
    --device /dev/megaraid_sas_ioctl_node:/dev/megaraid_sas_ioctl_node \    # Devices in RAID mode
	mecjay12/lsa
```

### Docker Compose

```
services:
  lsa:
    volumes:
      - /DataDir:/opt/lsi/LSIStorageAuthority/conf
      - /LogsDir:/opt/lsi/LSIStorageAuthority/logs
    cap_add:
      - SYS_ADMIN
    ports:
      - 2463:2463
      - 9000:9000
    environment:
      - TZ=America/New_York
      - ROOT_PASSWORD=password
      - ADD_USERS_RW=readWriteUser:password user2:password
      - ADD_USERS_RO=readOnlyUser:password
	devices:
      - /dev/mpt2ctl:/dev/mpt2ctl  									# Older devices in IT mode
      - /dev/mpt3ctl:/dev/mpt3ctl  									# Newer devices in IT mode
      - /dev/megaraid_sas_ioctl_node:/dev/megaraid_sas_ioctl_node   # Devices in RAID mode
    image: mecjay12/lsa
```

### Command Reference

<table>
	<thead>
		<tr>
			<th>Docker Run</th>
			<th rowspan=2>Required On*</th>
			<th rowspan=2>Effect</th>
		</tr>
		<tr>
			<th>Docker Compose</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<th align=left><pre>--detach</pre></th>
			<th rowspan=2>All</th>
			<th rowspan=2>Run the container in the background</th>
		</tr>
		<tr>
			<th align=left>N/A</th>
		</tr>
		<tr>
			<th align=left><pre>--cap-add SYS_ADMIN</pre></th>
			<th rowspan=2>Client</th>
			<th rowspan=2>Required on the host with the RAID card. Grants the container access to hardware PCI devices. If there is a more specific way to do this (like with --device) please let me know in a ticket.</th>
		</tr>
		<tr>
			<th align=left><pre>cap_add:<br>- SYS_ADMIN</pre></th>
		</tr>
		<tr>
			<th align=left><pre>--volume /DataDir:/opt/lsi/LSIStorageAuthority/conf</pre></th>
			<th rowspan=2>Server</th>
			<th rowspan=2>Mounts the config files to make the configuration persistant.</th>
		</tr>
		<tr>
			<th align=left><pre>volumes:<br>- /DataDir:/opt/lsi/LSIStorageAuthority/conf</pre></th>
		</tr>
		<tr>
			<th align=left><pre>--volume /LogsDir:/opt/lsi/LSIStorageAuthority/logs</pre></th>
			<th rowspan=2>Server</th>
			<th rowspan=2>Mounts the logs files to make the logs persistant.</th>
		</tr>
		<tr>
			<th align=left><pre>volumes:<br>- /LogsDir:/opt/lsi/LSIStorageAuthority/logs</pre></th>
		</tr>
		<tr>
			<th align=left><pre>--publish 2463:2463</pre></th>
			<th rowspan=2>Server</th>
			<th rowspan=2>Opens the port for the web interface. The default is 2463.</th>
		</tr>
		<tr>
			<th align=left><pre>ports:<br>- 2464:2463</pre></th>
		</tr>
		<tr>
			<th align=left><pre>--publish 9000:9000</pre></th>
			<th rowspan=2>Client, Optional</th>
			<th rowspan=2>Opens the port for remote management. The default port is 9000.</th>
		</tr>
		<tr>
			<th align=left><pre>ports:<br>- 9000:9000</pre></th>
		</tr>
		<tr>
			<th align=left><pre>--env TZ=America/New_York</pre></th>
			<th rowspan=2>Optional</th>
			<th rowspan=2>Sets timezone inside the container.</th>
		</tr>
		<tr>
			<th align=left><pre>environment:<br>- TZ=America/New_York</pre></th>
		</tr>
		<tr>
			<th align=left><pre>--env ROOT_PASSWORD="password"</pre></th>
			<th rowspan=2>Optional</th>
			<th rowspan=2>Sets the password for the root user to login to the web interface.</th>
		</tr>
		<tr>
			<th align=left><pre>environment:<br>- ROOT_PASSWORD=password</pre></th>
		</tr>
		<tr>
			<th align=left><pre>--env ADD_USERS_RW=<br>"readWriteUser:password user2:password"</pre></th>
			<th rowspan=2>Optional</th>
			<th rowspan=2>Creates additional users with read/write permission in the web interface. Users should be in username:password format with spaces between users.</th>
		</tr>
		<tr>
			<th align=left><pre>environment:<br>- ADD_USERS_RW=<br>readWriteUser:password user2:password</pre></th>
		</tr>
		<tr>
			<th align=left><pre>--env ADD_USERS_RO=<br>"readOnlyUser:password"</pre></th>
			<th rowspan=2>Optional</th>
			<th rowspan=2>Creates additional users with read-only permission in the web interface. Users should be in username:password format with spaces between users.</th>
		</tr>
		<tr>
			<th align=left><pre>environment:<br>- ADD_USERS_RO=<br>readOnlyUser:password</pre></th>
		</tr>
		<tr>
			<th align=left><pre>environment:<br>- ADD_USERS_RW=<br>readWriteUser:password user2:password</pre></th>
		</tr>
		<tr>
			<th align=left><pre>--device /dev/mpt2ctl:/dev/mpt2ctl</pre></th>
			<th rowspan=2>Optional</th>
			<th rowspan=2>Required to grant access from the container to older devices in IT mode</th>
		</tr>
		<tr>
			<th align=left><pre>devices:<br>- /dev/mpt2ctl:/dev/mpt2ctl</pre></th>
		</tr>
		<tr>
			<th align=left><pre>--device /dev/mpt3ctl:/dev/mpt3ctl</pre></th>
			<th rowspan=2>Optional</th>
			<th rowspan=2>Required to grant access from the container to newer devices in IT mode</th>
		</tr>
		<tr>
			<th align=left><pre>devices:<br>- /dev/mpt3ctl:/dev/mpt3ctl</pre></th>
		</tr>
		<tr>
			<th align=left><pre>mecjay12/lsa</pre></th>
			<th rowspan=2>All</th>
			<th rowspan=2>Pulls the latest stable version of this container.</th>
		</tr> 
		<tr>
			<th align=left><pre>--device /dev/megaraid_sas_ioctl_node:/dev/megaraid_sas_ioctl_node</pre></th>
			<th rowspan=2>Optional</th>
			<th rowspan=2>Required to grant access from the container to devices in RAID mode</th>
		</tr>
		<tr>
			<th align=left><pre>devices:<br>- /dev/megaraid_sas_ioctl_node:/dev/megaraid_sas_ioctl_node</pre></th>
		</tr>
		<tr>
			<th align=left><pre>mecjay12/lsa</pre></th>
			<th rowspan=2>All</th>
			<th rowspan=2>Pulls the latest stable version of this container.</th>
		</tr>
		<tr>
			<th align=left><pre>image: mecjay12/lsa</pre></th>
		</tr>
	</tbody>
</table>

* Client refers to the machine with the RAID card, Server refers to the machine hosting the web interface. A single machine can be both.

## Links

[Docker Hub](https://hub.docker.com/repository/docker/mecjay12/lsa/general)

[GitHub](https://github.com/MeCJay12/lsi-storage-authority/)
