FROM nginx

RUN apt-get update && apt-get install -y \
	openssl \
	nginx-extras lua5.1 liblua5.1-dev \
	git diffutils autoconf libssl1.0-dev make \
	&& rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/dersimn/luacrypto /opt/luacrypto \
	&& cd /opt/luacrypto \
	&& autoreconf -i \
	&& ./configure \
	&& make \
	&& mkdir -p /usr/local/lib/lua/5.1 \
	&& cp src/.libs/crypto.so /usr/local/lib/lua/5.1/crypto.so

COPY nginx /conf
COPY entrypoint.bash /entrypoint.bash

CMD ["bash", "/entrypoint.bash"]
