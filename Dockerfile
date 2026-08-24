FROM debian:stable-slim

COPY docker-run.sh /
RUN \
  apt-get update \
  && apt-get -y install --no-install-recommends \
    wget \
  && chmod +x /docker-run.sh \
  && mkdir -p /usr/local/ezproxy/config \
  && wget --no-check-certificate -O /usr/local/ezproxy/ezproxy https://help.oclc.org/@api/deki/files/9850/ezproxy-linux.bin \
  && chmod +x /usr/local/ezproxy/ezproxy \
  && apt-get purge -y \
    wget \
  && apt-get clean autoclean autoremove -y \
  && rm -rf /var/lib/apt/lists/*

ENV EZPROXY_WSKEY=
VOLUME /usr/local/ezproxy/config
EXPOSE 2048

CMD ["/docker-run.sh"]