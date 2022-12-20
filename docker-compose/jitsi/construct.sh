#!/usr/bin/env bash

# This file is specific to the docker-compose you are spinning up
# which means you cannot use this as is without modifications in other
# applications you try to spin up.

#Update with production domain name, change this to your domain name
PUBLIC_URL=jitsi.yourdomain.com
#Update with your TorGuard Wireguard IP
VPN_IP=1.2.3.4
# set our password for the admin username
JITSI_PASS=torguard2022!

cd /opt/docker2/compose/jitsi

# Get our running directory
#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#Download the latest stable jitsi release
wget https://github.com/jitsi/docker-jitsi-meet/archive/refs/tags/stable-8138-1.tar.gz

chmod 777 stable-8138-1.tar.gz

tar xzvf /opt/docker2/compose/jitsi/stable-8138-1.tar.gz -C /opt/docker2/compose/jitsi/

cd /opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/

cp /opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/env.example /opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/.env

# Edit our .env to enable public URL (required)
sed -i -e "s/#PUBLIC_URL=/PUBLIC_URL=/g" "/opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/.env"

# Edit our .env to set public URL (required)
sed -i -e "s/meet.example.com/${PUBLIC_URL}/g" "/opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/.env"

# Change JVB http port
sed -i -e "s/# JaaS Components (beta)/JVB_COLIBRI_PORT=8088/g" "/opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/.env"

# Set local IP and Wireguard for WebRTC
sed -i -e "s/#JVB_ADVERTISE_IPS=192.168.1.1,1.2.3.4/JVB_ADVERTISE_IPS=192.168.70.1,${VPN_IP}/g" "/opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/.env"

# Set container restart policy
sed -i -e "s/#RESTART_POLICY=unless-stopped/RESTART_POLICY=unless-stopped/g" "/opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/.env"

# Enable Auth
sed -i -e "s/#ENABLE_AUTH=1/ENABLE_AUTH=1/g" "/opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/.env"

# Enable guest access
sed -i -e "s/#ENABLE_GUESTS=1/ENABLE_GUESTS=1/g" "/opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/.env"

# Set Auth type to internal
sed -i -e "s/#AUTH_TYPE=internal/AUTH_TYPE=internal/g" "/opt/docker2/compose/jitsi/docker-jitsi-meet-stable-8138-1/.env"

#Set strong passwordss
./gen-passwords.sh

#make config directory
mkdir -p ~/.jitsi-meet-cfg/{web,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}

docker-compose up -d

docker-compose exec prosody /bin/bash -c "prosodyctl --config /config/prosody.cfg.lua register host meet.jitsi ${JITSI_PASS}"

# Do our dynamic link just because we have to have it
# ln -s "${SCRIPT_DIR}/env" "${SCRIPT_DIR}/.env"

# Delete ourself and exit!
#rm -- "$0"
