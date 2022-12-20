#!/usr/bin/env bash

# This file is specific to the docker-compose you are spinning up
# which means you cannot use this as is without modifications in other
# applications you try to spin up.

#Update with production domain name, change this to your domain name
PUBLIC_URL=peertube.yourdomain.com
#Update with your router IP
ROUTER_IP=192.168.70.1
#Update with peertube admin email
ADMIN_EMAIL=email@yourdomain.com

# Get our running directory
SCRIPT_DIR=/opt/docker2/compose/peertube/PeerTube/support/docker/production

git clone https://github.com/Chocobozzz/PeerTube.git

rm /opt/docker2/compose/peertube/PeerTube/support/docker/production/docker-compose.yml

cp /opt/docker2/compose/peertube/docker-compose.yml /opt/docker2/compose/peertube/PeerTube/support/docker/production/docker-compose.yml

cd /opt/docker2/compose/peertube/PeerTube/support/docker/production

chmod 777 "/opt/docker2/compose/peertube/PeerTube/support/docker/production/.env"

# We should only be executed in our output directory so we assume we output to the correct directory
#wget -O "${SCRIPT_DIR}/env" https://raw.githubusercontent.com/Chocobozzz/PeerTube/master/support/docker/production/.env

#chmod 777 "${SCRIPT_DIR}/env"

# Edit DOCKER COMPOSE
#sed -i -e "s/80:80/84:80/g" "${SCRIPT_DIR}/docker-compose.yml"
#sed -i -e "s/443:443/4143:443/g" "${SCRIPT_DIR}/docker-compose.yml"
#sed -i -e "s/source: ./docker-volume/nginx/peertube/#source: ./docker-volume/nginx/peertube/g" "${SCRIPT_DIR}/docker-compose.yml"
#sed -i -e "s/#source: ../../nginx/peertube/source: ../../nginx/peertube/g" "${SCRIPT_DIR}/docker-compose.yml"

# Generate our password for the database
GEN_PASS=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c14; echo)

# Generate our peertube secret
GEN_SECRET=$(openssl rand -hex 32 | sed 's/\(..\)/\1:/g; s/.$//')

# Edit our .env to change postgres username
sed -i -e "s/<MY POSTGRES USERNAME>/postgres1/g" "${SCRIPT_DIR}/.env"

# Edit our .env to change postgres password
sed -i -e "s/<MY POSTGRES PASSWORD>/${GEN_PASS}/g" "${SCRIPT_DIR}/.env"

# Edit our .env to change peertube domain
sed -i -e "s/<MY DOMAIN>/${PUBLIC_URL}/g" "${SCRIPT_DIR}/.env"

# Edit our .env to change peertube trusted proxy
sed -i -e "s/127.0.0.1/${ROUTER_IP}/g" "${SCRIPT_DIR}/.env"

# Edit our .env to change peertube trusted proxy
sed -i -e "s/<MY EMAIL ADDRESS>/${ADMIN_EMAIL}/g" "${SCRIPT_DIR}/.env"

# Edit our .env to enable signup (comment out to disable signup)
sed -i -e "s/#PEERTUBE_SIGNUP_ENABLED=true/PEERTUBE_SIGNUP_ENABLED=true/g" "${SCRIPT_DIR}/.env"

# Edit our .env to set the LAN IP var that is no where mentioned in the peertub env file but yet required
sed -i -e "s/# PeerTube server configuration/LAN_IP=${ROUTER_IP}/g" "${SCRIPT_DIR}/.env"

# Do our dynamic link just because we have to have it
#ln -s "${SCRIPT_DIR}/env" "${SCRIPT_DIR}/.env"

docker-compose up -d

# Delete ourself and exit!
#rm -- "$0"

