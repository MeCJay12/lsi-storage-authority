FROM ubuntu:focal

ENV PASSWORD="password"
ENV WEB_PORT="2463"
ENV LSA_PORT="9000"
# Find the latest version by going to https://docs.broadcom.com/docs/1232744305 and checking the download URL
ENV DOWNLOAD_URL="https://docs.broadcom.com/docs-and-downloads/008.011.010.000_MR%207.31_LSA%20Linux.zip"
ENV TERM=xterm

RUN apt -y update && apt -y install wget unzip libldap2-dev
COPY entrypoint.sh /

RUN mkdir -p /MSM && \
	wget -O /MSM.zip $DOWNLOAD_URL && \
	unzip -d /MSM /MSM.zip && \
	rm -f /MSM.zip && \
  unzip -d /MSM /MSM/webgui_rel/LSA_Linux.zip
WORKDIR /MSM/gcc_8.3.x/
RUN dpkg -i LSA_lib_utils2-*.deb && \
	bash install_deb.sh -s $WEB_PORT $LSA_PORT 2 && \
	mkdir -p /usr/local/var/log/ && \
	touch /usr/local/var/log/slpd.log && \
	mv /opt/lsi/LSIStorageAuthority/conf /opt/lsi/backup && \
	rm -rf /MSM
COPY LsiSASH /etc/init.d/LsiSASH
WORKDIR /

ENTRYPOINT ["/entrypoint.sh"]
