#!/bin/bash

nginx_port=$WEB_PORT # Run script will set the LSA webUI port to the value of nginx_port
LSA_port=$LSA_PORT # Run script will set the LSA control port to the value of LSA_port
# $ROOT_PASSWORD Will be set as the root password/default login
# $ADD_USERS_RW List of RW users in space seperated username:password format
# $ADD_USERS_RO List of RO users in space seperated username:password format

# Function to create webUI passwords
# $1 = Unparsed, individual user in username:password
# $2 = Group to add user to; root for RW, users for RO
add_user () {
	USR=$(echo "$1" |cut -d ':' -f 1)

	useradd -G "$2" "$USR"
	echo "$1" | chpasswd
}

# Copies LSA files in case user mounted empty dir to server dir to svae config files
mkdir -p /opt/lsi/LSIStorageAuthority/conf/
cp -rn /opt/lsi/backup/* /opt/lsi/LSIStorageAuthority/conf/

if [[ ! -z "$ROOT_PASSWORD" ]] ; then
	echo "root:$ROOT_PASSWORD" | chpasswd
fi

for USR in ${ADD_USERS_RW[@]} ; do
	add_user "$USR" "root"
done

for USR in ${ADD_USERS_RO[@]} ; do
	add_user "$USR" "users"
done

/etc/init.d/LsiSASH start
