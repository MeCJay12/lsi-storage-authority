FROM ubuntu:jammy

ENV PASSWORD="password"
ENV WEB_PORT="2463"
ENV LSA_PORT="9000"
ENV BASEURL="https://docs.broadcom.com/docs-and-downloads"
ENV VERSION="008.012.007.000_MR7.32_LSA_Linux.zip"
ENV TERM=xterm

RUN apt -y update && apt -y install wget unzip libldap2-dev libgssapi3-heimdal
COPY entrypoint.sh /
RUN chmod +x entrypoint.sh
COPY LsiSASH /

RUN mkdir /MSM && \
	wget -O /MSM.zip ${BASEURL}/${VERSION} && \
	unzip -d /MSM /MSM.zip && \
	find . -iname '*.zip' -exec sh -c 'unzip -o -d "${0%.*}" "$0"' '{}' ';'
WORKDIR /MSM/webgui_rel/LSA_Linux/gcc\_11\.2\.x

#installing obsolete dependencies
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
	dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
	rm libssl1.1_1.1.0g-2ubuntu4_amd64.deb

RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openldap/libldap-2.4-2_2.4.49+dfsg-2ubuntu1_amd64.deb && \
	dpkg -i libldap-2.4-2_2.4.49+dfsg-2ubuntu1_amd64.deb && \
	rm libldap-2.4-2_2.4.49+dfsg-2ubuntu1_amd64.deb

RUN dpkg -i LSA_lib_utils2-9.00-1_amd64.deb && \
	chmod +x ./RunDEB.sh && \
	bash install_deb.sh -s $WEB_PORT $LSA_PORT 2 && \
	cp /LsiSASH /etc/init.d/LsiSASH && \
	mkdir -p /usr/local/var/log/ && \
	touch /usr/local/var/log/slpd.log && \
	mv /opt/lsi/LSIStorageAuthority /opt/lsi/backup && \
	rm -rf /MSM
WORKDIR /

ENTRYPOINT ["/entrypoint.sh"]