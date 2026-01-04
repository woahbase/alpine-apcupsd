# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
RUN set -xe \
    && apk add --no-cache --purge -uU \
        # --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        ca-certificates \
        apcupsd \
        apcupsd-webif \
        lighttpd \
    # ensure lighttpd reads apcupsd.conf
    && echo 'include "apcupsd.conf"' >> /etc/lighttpd/lighttpd.conf \
    # move files to defaults/
    && mkdir -p /defaults/apcupsd.defaults \
    && mv /etc/apcupsd/* /defaults/apcupsd.defaults/ \
    && mv /etc/lighttpd/lighttpd.conf /defaults/lighttpd.conf.default \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME /etc/apcupsd/
#
EXPOSE 3551/tcp 3551/udp 80/tcp
#
HEALTHCHECK \
    --interval=2m \
    --retries=5 \
    --start-period=5m \
    --timeout=10s \
    CMD \
    apcaccess -h ${HEALTHCHECK_HOST:-"localhost:3551"} -p ${HEALTHCHECK_PARAM:-DATE} || exit 1
#
ENTRYPOINT ["/init"]
