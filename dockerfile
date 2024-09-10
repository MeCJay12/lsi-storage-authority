FROM ubuntu:focal

ENV PASSWORD="password"
ENV WEB_PORT="2463"
ENV LSA_PORT="9000"
ENV VERSION="007.020.016.000"
ENV TERM=xterm

RUN apt -y update && apt -y install wget unzip libldap2-dev
COPY entrypoint.sh /
COPY LsiSASH /

RUN mkdir /MSM && \
	wget -O /MSM.zip https://docs.broadcom.com/docs-and-downloads/raid-controllers/raid-controllers-common-files/${VERSION}_LSA_Linux_x64.zip && \
	unzip -d /MSM /MSM.zip && \
	rm -f /MSM.zip
WORKDIR /MSM/x64/
RUN dpkg -i LSA_lib_utils2-8.00-1_amd64.deb && \
	bash install_deb.sh -s $WEB_PORT $LSA_PORT 2 && \
	cp /LsiSASH /etc/init.d/LsiSASH && \
	mkdir -p /usr/local/var/log/ && \
	touch /usr/local/var/log/slpd.log && \
	mv /opt/lsi/LSIStorageAuthority/conf /opt/lsi/backup && \
	rm -rf /MSM
WORKDIR /

ENTRYPOINT ["/entrypoint.sh"]
