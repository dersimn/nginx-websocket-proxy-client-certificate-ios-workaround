#!/bin/bash
set -e

CONFIG_PATH="/etc/nginx/sites-enabled/default"

# Build Nginx config
echo "# Generated config" > ${CONFIG_PATH}

# Geo locations
cat /conf/10-geo.conf >> ${CONFIG_PATH}
if [ -n "${DISABLE_LAN_SECURITY}" ]; then
	echo "${DISABLE_LAN_SECURITY} 0;" >> ${CONFIG_PATH}
fi
echo "}" >> ${CONFIG_PATH}

# Server
echo "server {" >> ${CONFIG_PATH}
cat /conf/20-server.conf >> ${CONFIG_PATH}

# SSL
if [ -n "${SSL_HOSTNAME}" ] && [ ! -e /ssl/nginx.key ] && [ ! -e /ssl/nginx.crt ]; then
	mkdir -p /ssl
	openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /ssl/nginx.key -out /ssl/nginx.crt -subj "/O=MQTT-Smarthome/CN=${SSL_HOSTNAME}"
fi
if [ -f /ssl/nginx.key ] && [ -f /ssl/nginx.crt ]; then
	cat /conf/30-ssl.conf >> ${CONFIG_PATH}
fi
if [ -f /ssl/client.crt ]; then
	cat /conf/41-ssl-client-auth.conf >> ${CONFIG_PATH}
fi

# HTTP auth
if [ -n "${HTTP_AUTH}" ]; then
	htpasswd -bc /htpasswd ${HTTP_AUTH}
	cat /conf/40-auth.conf >> ${CONFIG_PATH}
fi

# Location directives
# /
cat /conf/80-location.conf >> ${CONFIG_PATH}
if [ -f /ssl/client.crt ]; then
	echo "access_by_lua_file /conf/90-wsrelay-access.lua;" >> ${CONFIG_PATH}
fi
echo "}" >> ${CONFIG_PATH}
# /mqtt
if [ -n "${MQTT_WS_URL}" ]; then
	envsubst '${MQTT_WS_URL}' < /conf/90-wsrelay.conf >> ${CONFIG_PATH}
	if [ -f /ssl/client.crt ]; then
		echo "access_by_lua_file /conf/90-wsrelay-access.lua;" >> ${CONFIG_PATH}
	fi
	echo "}" >> ${CONFIG_PATH}
fi
# = / (exactly root)
if [ -f /ssl/client.crt ]; then
	cat /conf/81-location-root-workaround.conf >> ${CONFIG_PATH}
fi

# Server close
echo "}" >> ${CONFIG_PATH}

# Run
cat ${CONFIG_PATH} 
exec nginx -g "daemon off;"
