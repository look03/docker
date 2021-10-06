FROM nginx:1.14

LABEL maintainer="Areal <hello@arealidea.ru>"

RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests curl netcat && \
    usermod -u 1000 nginx && \
    groupmod -g 1000 nginx

COPY ./rootfs /

HEALTHCHECK --interval=5s --timeout=3s CMD curl -f http://localhost/status/ || exit 1
