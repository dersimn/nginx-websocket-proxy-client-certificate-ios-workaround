#!/bin/bash
set -e

# Build Nginx config
rm /etc/nginx/conf.d/default.conf

# Geo locations
cat /conf/10-geo.conf >> /etc/nginx/conf.d/default.conf
if [ -n "${DISABLE_LAN_SECURITY}" ]; then
	echo "${DISABLE_LAN_SECURITY} 0;" >> /etc/nginx/conf.d/default.conf
fi
echo "}" >> /etc/nginx/conf.d/default.conf

# Server
echo "server {" >> /etc/nginx/conf.d/default.conf
cat /conf/20-server.conf >> /etc/nginx/conf.d/default.conf

# SSL
if [ -n "${SSL_HOSTNAME}" ] && [ ! -e /ssl/nginx.key ] && [ ! -e /ssl/nginx.crt ]; then
	mkdir -p /ssl
	openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /ssl/nginx.key -out /ssl/nginx.crt -subj "/O=MQTT-Smarthome/CN=${SSL_HOSTNAME}"
fi
if [ -f /ssl/nginx.key ] && [ -f /ssl/nginx.crt ]; then
	cat /conf/30-ssl.conf >> /etc/nginx/conf.d/default.conf
fi
if [ -f /ssl/client.crt ]; then
	cat /conf/41-ssl-client-auth.conf >> /etc/nginx/conf.d/default.conf
fi

# HTTP auth
if [ -n "${HTTP_AUTH}" ]; then
	echo ${HTTP_AUTH} > /htpasswd
	cat /conf/40-auth.conf >> /etc/nginx/conf.d/default.conf
fi

# Location directives
# /
cat /conf/80-location.conf >> /etc/nginx/conf.d/default.conf
if [ -f /ssl/client.crt ]; then
	echo "access_by_lua_file /conf/90-wsrelay-access.lua;" >> /etc/nginx/conf.d/default.conf
fi
echo "}" >> /etc/nginx/conf.d/default.conf
# /mqtt
if [ -n "${MQTT_WS_URL}" ]; then
	envsubst '${MQTT_WS_URL}' < /conf/90-wsrelay.conf >> /etc/nginx/conf.d/default.conf
	if [ -f /ssl/client.crt ]; then
		echo "access_by_lua_file /conf/90-wsrelay-access.lua;" >> /etc/nginx/conf.d/default.conf
	fi
	echo "}" >> /etc/nginx/conf.d/default.conf
fi

# Server close
echo "}" >> /etc/nginx/conf.d/default.conf

# Run
cat /etc/nginx/conf.d/default.conf 
exec nginx -g "daemon off;"
