FROM ubuntu:jammy AS builder

ENV BASEURL="https://docs.broadcom.com/docs-and-downloads"
ENV VERSION="008.014.012.000_MR7.34"
ENV ARCH="Linux"

RUN apt -y update && \
	apt -y install wget unzip && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir /MSM && \
	wget -O /MSM.zip ${BASEURL}/${VERSION}_LSA_${ARCH}.zip && \
	unzip -d /MSM /MSM.zip && \
	cd /MSM && \
	find . -iname '*.zip' -exec sh -c 'unzip -o -d "${0%.*}" "$0"' '{}' ';' && \
	find . -iname '*.zip' -delete

# Final stage
FROM ubuntu:jammy

ENV PASSWORD="password"
ENV WEB_PORT="2463"
ENV LSA_PORT="9000"
ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive

RUN apt -y update && \
	apt -y install --no-install-recommends libldap2-dev libgssapi3-heimdal wget && \
	wget -q http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
	wget -q http://archive.ubuntu.com/ubuntu/pool/main/o/openldap/libldap-common_2.4.49+dfsg-2ubuntu1_all.deb && \
	wget -q http://archive.ubuntu.com/ubuntu/pool/main/o/openldap/libldap-2.4-2_2.4.49+dfsg-2ubuntu1_amd64.deb && \
	dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
	dpkg -i libldap-common_2.4.49+dfsg-2ubuntu1_all.deb && \
	dpkg -i libldap-2.4-2_2.4.49+dfsg-2ubuntu1_amd64.deb && \
	rm -f *.deb && \
	apt -y remove wget && \
	apt -y autoremove && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /
COPY LsiSASH /
RUN chmod +x /entrypoint.sh

COPY --from=builder /MSM/webgui_rel/LSA_Linux/gcc_11.2.x /MSM/webgui_rel/LSA_Linux/gcc_11.2.x

WORKDIR /MSM/webgui_rel/LSA_Linux/gcc_11.2.x

RUN dpkg -i LSA_lib_utils2-9.00-1_amd64.deb && \
	chmod +x ./RunDEB.sh && \
	bash install_deb.sh -s $WEB_PORT $LSA_PORT 2 && \
	cp /LsiSASH /etc/init.d/LsiSASH && \
	mkdir -p /usr/local/var/log/ && \
	touch /usr/local/var/log/slpd.log && \
	mv /opt/lsi/LSIStorageAuthority /opt/lsi/backup && \
	cd / && \
	rm -rf /MSM

WORKDIR /

ENTRYPOINT ["/entrypoint.sh"]