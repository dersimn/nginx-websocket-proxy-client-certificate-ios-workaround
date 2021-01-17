#!/bin/bash
set -e

CONFIG_PATH="/etc/nginx/nginx.conf"

# Get settings
if [ -f /ssl/nginx.key ] && [ -f /ssl/nginx.crt ]; then
	export ENABLE_HTTPS=true
fi
if [ -f /ssl/client.crt ]; then
	export SSL_CLIENT_AUTH=true
fi
if [ -f /ssl/client.crl ]; then
	export SSL_CLIENT_AUTH_CRL=true
fi
if [[ -z "${HTTPS_REDIRECT_PORT}" ]]; then
	export HTTPS_REDIRECT_PORT=""
else
	export HTTPS_REDIRECT_PORT=":${HTTPS_REDIRECT_PORT}"
fi
if [ -f /nginx.log ]; then
    export ACCESS_LOG_FILE=true
fi
if [[ -z "${WS_PROXY_PATH}" ]]; then
    export WS_PROXY_PATH="/ws"
fi
if [[ -z "${HMAC_SECRET}" ]]; then
    export HMAC_SECRET="hunter2"
fi

# Build Config
export MO_FALSE_IS_EMPTY=true
cat /nginx.template | mo > ${CONFIG_PATH}

# Run
cat ${CONFIG_PATH} 
exec nginx -g "daemon off;"
