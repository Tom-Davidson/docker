#!/bin/bash

# Update the Apache config from the ENV vars
mkdir -p /etc/apache2/ssl/ssl.key
echo "${PRIVATE_KEY}" | base64 -d | sed 's/\\n/\n/g' > /etc/apache2/ssl/ssl.key/simplerisk.key
mkdir -p /etc/apache2/ssl/ssl.crt
echo "${CERTIFICATE}" | base64 -d | sed 's/\\n/\n/g' > /etc/apache2/ssl/ssl.crt/simplerisk.crt

# Update the SimpleRisk config file from the ENV vars
cat /var/www/config.orig.php | \
 sed "s/DB_HOSTNAME', 'localhost/DB_HOSTNAME', '${MYSQL_HOSTNAME}/" | \
 sed "s/DB_PASSWORD', 'simplerisk/DB_PASSWORD', '${MYSQL_PASSWORD}/" | \
 sed "s/DB_USERNAME', 'simplerisk/DB_USERNAME', '${MYSQL_USER}/" | \
 sed "s:DB_SSL_CERTIFICATE_PATH', ':DB_SSL_CERTIFICATE_PATH', '${MYSQL_SSL_CERTIFICATE_PATH:-}:" \
 > /var/www/simplerisk/includes/config.php

# Start Apache
/usr/sbin/apache2ctl -D FOREGROUND
