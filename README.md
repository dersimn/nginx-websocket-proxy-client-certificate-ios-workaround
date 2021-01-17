Docker Image with nginx and configurable websocket proxy with SSL client certifcate authorization.  
This image includes a workaround for iOS Safari, as there is still an open bug that causes the SSL client certificate not being used for websocket connections, see [[1]](http://blog.christophermullins.com/2017/04/30/securing-homeassistant-with-client-certificates) [[2]](https://github.com/home-assistant/home-assistant-iOS/issues/27) [[3]](https://www.bountysource.com/issues/35354552-websocket-does-not-send-client-certificate).

I started to build this image to proxy Mosquitto MQTT websockets, but it will work with every websocket connection. 


## Options

This image can proxy-pass the Websocket connections, by setting the env variable `WS_PROXY`. The target path for the proxy can be configured with `WS_PROXY_PATH`, it defaults to `/ws`.

    docker run -d --restart=always \
        -v $(pwd)/www:/www:ro \
        -e "WS_PROXY=10.1.1.50:9001" \
        -p 80:80 \
        dersimn/nginx-websocket-proxy-client-certificate-ios-workaround

If you provide an SSL key/cert pair in `/ssl`, the Docker Image will also enable HTTPS:

* `/ssl/nginx.key`
* `/ssl/nginx.crt`

Additionally you can enable client-authentification via SSL certificates, by providing:

* `/ssl/client.crt`

In case you have revoked clients, also prodive a `/ssl/client.crl` file.

A nice tutorial on how to generate your own certificates, is located [here](https://jamielinux.com/docs/openssl-certificate-authority/introduction.html).

    docker run -d --restart=always \
        -v $(pwd)/www:/www:ro \
        -v $(pwd)/ssl:/ssl:ro \
        -e "WS_PROXY=10.1.1.50:9001" \
        -p 80:80 \
        -p 443:443 \
        dersimn/nginx-websocket-proxy-client-certificate-ios-workaround

If you want to change the default ports, specify it like this: `-p 8001:80 -p 8443:443 -e "HTTPS_REDIRECT_PORT=8443"`.

HTTPS and client-auth are optional for clients connecting from a local IP, according to [these](https://github.com/dersimn/nginx-websocket-proxy-client-certificate-ios-workaround/blob/3d8123b9830f49b9c1b3ef9176ef6c8fe22353dd/nginx.template#L90) IP ranges. If you don't want this behaviour, set `-e WHITELIST_LOCAL_IP=false` to force SSL and client-auth for everyone. You can also add own IP ranges to the whitelist with `-e WHITELIST_IP="10.1.1.0/24 192.168.1.0/24"`.

## iOS Client Certificate Workaround

The workaround is based on a [Keyed-Hash Message Authentication Code (HMAC)](https://en.wikipedia.org/wiki/HMAC) and was initially described by [Chris Mullins](https://github.com/sidoh) for Securing HomeAssistant with client certificates (works with Safari/iOS) [[1]](https://blog.christophermullins.com/2017/04/30/securing-homeassistant-with-client-certificates). 

By connecting to `/` a cookie will be generated that is used to authenticate the websocket connection later, as there is an open bug that iOS Safari is not using the client certificate for authenticating websocket conenctions [[3]](https://www.bountysource.com/issues/35354552-websocket-does-not-send-client-certificate). It is also possible to use a dedicated cookie location to generate the previously mentioned cookie, by setting `-e DEDICATED_COOKIE_LOCATION="/cookie"`. However this requires your application to fetch the cookie prior to connecting to the websocket location, see an example [here](https://github.com/dersimn/mqtt-smarthome-webui/blob/9d74c4d5370c2e2249f8941abe35e0323d6bc4c8/www/webui.js#L60). 

The HMAC secret can be customized by `-e HMAC_SECRET="some secret"`.

