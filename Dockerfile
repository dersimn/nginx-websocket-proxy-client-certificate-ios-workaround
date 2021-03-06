FROM ubuntu:18.04 as builder

RUN apt-get update && apt-get install -y \
        build-essential \
        lua5.1 liblua5.1-dev \
        git \
        autoconf \
        libssl1.0-dev \
        curl

RUN git clone https://github.com/dersimn/luacrypto /opt/luacrypto \
    && cd /opt/luacrypto \
    && autoreconf -i \
    && ./configure \
    && make

RUN curl -sSL -o /mo https://git.io/get-mo && chmod a+x /mo

# ------------------------------------------------------------------------------

FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
        nginx-extras \
        lua5.1 \
        libssl1.0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/luacrypto/src/.libs/crypto.so /usr/local/lib/lua/5.1/crypto.so
COPY --from=builder /mo /usr/local/bin/mo

RUN mkdir /www
COPY nginx.template /nginx.template
COPY run.bash /run.bash

EXPOSE 80
EXPOSE 443

ENV WHITELIST_LOCAL_IP true

CMD ["bash", "/run.bash"]
