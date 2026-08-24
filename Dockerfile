FROM debian:stable-slim

COPY docker-run.sh /
RUN \
  apt-get update \
  && apt-get -y install --no-install-recommends \
    ca-certificates \
    libcap2-bin \
    wget \
  && chmod +x /docker-run.sh \
  && mkdir -p /usr/local/ezproxy/config \
  && wget -O /usr/local/ezproxy/ezproxy https://help.oclc.org/@api/deki/files/9850/ezproxy-linux.bin \
  && chmod +x /usr/local/ezproxy/ezproxy \
  && setcap 'cap_net_bind_service=+ep' /usr/local/ezproxy/ezproxy \
  && groupadd --system --gid 999 ezproxy \
  && useradd --system --no-create-home --shell /usr/sbin/nologin --uid 999 --gid ezproxy ezproxy \
  && chown -R ezproxy:ezproxy /usr/local/ezproxy \
  && apt-get purge -y \
    libcap2-bin \
    wget \
  && apt-get clean autoclean autoremove -y \
  && rm -rf /var/lib/apt/lists/*

ENV EZPROXY_WSKEY=
VOLUME /usr/local/ezproxy/config
EXPOSE 2048

USER ezproxy
CMD ["/docker-run.sh"]