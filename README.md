Nginx Docker image, with configurable config templates that might be useful for [mqtt-smarthome](https://github.com/mqtt-smarthome).

## Options

Enable the following options via ENV varables, either by `docker run ... -e "SOME_ENV=somevalue" ...` or in yaml format via docker-compose:

* `MQTT_WS_URL=http://mosquitto:9001`: Proxy websocket from given url to http://example.com/mqtt. Useful when your clients and the MQTT broker are not in the same network (e.g. Internet).
* `HTTP_AUTH=user password`: Basic HTTP authentification. Passwords are transmitted in plaintext via HTTP. Better don't use one of your default passwords here. Alternatively: enable HTTPS.
* `SSL_HOSTNAME=example.com`: Enable HTTPS by generating self-signed certificates, which will be placed in `/ssl`.
* If you provide certificate files (`/ssl/nginx.crt`, `/ssl/nginx.key`) for e.g. via: `docker run ... -v $(pwd)/ssl:/ssl:ro ...`, SSL will automatically be enabled.
* If you provide a client-side certificate (`/ssl/client.crt`), client authentification will be enabled. This branch includes a workaround for iOS, see [this](http://blog.christophermullins.com/2017/04/30/securing-homeassistant-with-client-certificates/), [this](https://github.com/home-assistant/home-assistant-iOS/issues/27), [this](https://www.bountysource.com/issues/35354552-websocket-does-not-send-client-certificate). Due to this workaround, only `index.htm` (not `.html`) will be loaded when navigating to `http://host/`.
* `LOCAL_NETWORK=10.1.1.0/24`: Disable HTTPS and HTTP Auth for the given IP range. For e.g. if these features should only be enabled for clients conencting from the Internet. When running on Docker for Mac, this feature doen't work, see [issue #180](https://github.com/docker/for-mac/issues/180).

### Example

docker-compose:

	version: '3'

	services:
	  web:
	    image: dersimn/mqtt-smarthome-nginx
	    restart: always
	    ports:
	      - "80:80"
	      - "443:443"
	    environment:
	      - SSL_HOSTNAME=home.simon-christmann.de
	      - HTTP_AUTH=user:password
	      - MQTT_WS_URL=http://10.1.1.50:9001
	      - DISABLE_LAN_SECURITY=10.1.1.0/24
	    volumes:
	      - ./www:/www:ro
	      - generated_ssl_certs:/ssl

	volumes:
	  generated_ssl_certs:

## Development

While actively developing the HTML scripts you can start a Docker Container with the following command:

	docker run -d --rm -v $(pwd)/www:/www:ro -p 8080:80 dersimn/mqtt-smarthome-nginx

### Build

For deploying a Docker Image, use this as your Dockerfile:

	FROM dersimn/mqtt-smarthome-nginx

	COPY www /www
