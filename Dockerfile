FROM nginx

RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY nginx /conf
COPY entrypoint.bash /entrypoint.bash

CMD ["bash", "/entrypoint.bash"]
