FROM debian:trixie AS builder

ENV BASEURL="https://docs.broadcom.com/docs-and-downloads"
ENV VERSION="008.018.012.000_MR_8.18_AV1_LSA_Linux.zip"
ENV ARCH="Linux"

RUN apt -y update && \
	apt -y install wget unzip && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir /MSM && \
	wget -O /MSM.zip ${BASEURL}/${VERSION} && \
	unzip -d /MSM /MSM.zip && \
	cd /MSM && \
	find . -iname '*.zip' -exec sh -c 'unzip -o -d "${0%.*}" "$0"' '{}' ';' && \
	find . -iname '*.zip' -delete

# Final stage
FROM debian:trixie

ENV PASSWORD="password"
ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive

RUN apt -y update && \
  apt -y install libldap2 procps wget

COPY entrypoint.sh /
COPY LsiSASH /
RUN chmod +x /entrypoint.sh

COPY --from=builder /MSM/webgui_rel/LSA_Linux/gcc_11.2.x /MSM/gcc_11.2.x

WORKDIR /MSM/gcc_11.2.x

RUN apt -y install ./LSA_lib_utils2-9.00-1_amd64.deb && \
	chmod +x ./RunDEB.sh && \
	bash install_deb.sh -s 2463 9000 2 && \
	cp /LsiSASH /etc/init.d/LsiSASH && \
	mkdir -p /usr/local/var/log/ && \
	touch /usr/local/var/log/slpd.log && \
	mv /opt/lsi/LSIStorageAuthority /opt/lsi/backup && \
	cd / && \
	rm -rf /MSM && \
	apt -y autoremove && \
  apt -y clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /
HEALTHCHECK CMD wget --spider -q http://localhost:2463 1>/dev/null || exit 1
ENTRYPOINT ["/entrypoint.sh"]