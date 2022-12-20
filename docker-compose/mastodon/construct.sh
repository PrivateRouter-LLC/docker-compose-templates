#!/usr/bin/env bash

# This file is specific to the docker-compose you are spinning up
# which means you cannot use this as is without modifications in other

#Update with production domain name, change this to your domain name
PUBLIC_URL=192.168.70.1

# Generate our password for the database
GEN_PASS=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c14; echo)

# Get our running directory
SCRIPT_DIR=/opt/docker2/compose/mastodon/

#out with the old
rm /opt/docker2/compose/mastodon/secrets/secretkeybase.txt
rm /opt/docker2/compose/mastodon/secrets/otpsecret.txt
rm /opt/docker2/compose/mastodon/secrets/vapidprivatekey.txt
rm /opt/docker2/compose/mastodon/secrets/vapidpublickey.txt

#in with the new
touch /opt/docker2/compose/mastodon/secrets/secretkeybase.txt
touch /opt/docker2/compose/mastodon/secrets/otpsecret.txt
touch /opt/docker2/compose/mastodon/secrets/vapidprivatekey.txt
touch /opt/docker2/compose/mastodon/secrets/vapidpublickey.txt

# rake secrets
echo $(docker run --rm -it -w /app/www --entrypoint rake lscr.io/linuxserver/mastodon secret) > /opt/docker2/compose/mastodon/secrets/secretkeybase.txt

echo $(docker run --rm -it -w /app/www --entrypoint rake lscr.io/linuxserver/mastodon secret) > /opt/docker2/compose/mastodon/secrets/otpsecret.txt

echo $(docker run --rm -it -w /app/www --entrypoint rake lscr.io/linuxserver/mastodon mastodon:webpush:generate_vapid_key) > /opt/docker2/compose/mastodon/secrets/vapidprivatekey.txt

echo $(docker run --rm -it -w /app/www --entrypoint rake lscr.io/linuxserver/mastodon mastodon:webpush:generate_vapid_key) > /opt/docker2/compose/mastodon/secrets/vapidpublickey.txt
#

#change db pass
sed -i -e "s/mastodondbpass/${GEN_PASS}/g" /opt/docker2/compose/mastodon/docker-compose.yml
#change web domain
sed -i -e "s/mastodon.example.com/${PUBLIC_URL}/g" /opt/docker2/compose/mastodon/docker-compose.yml
sed -i -e "s/example.com/${PUBLIC_URL}/g" /opt/docker2/compose/mastodon/docker-compose.yml

docker-compose up -d


