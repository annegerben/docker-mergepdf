FROM ubuntu:17.10

LABEL version="1.0.3"
LABEL maintainer="robert@verst.eu"

RUN apt-get update && apt-get -y install build-essential unzip \
    wget pdftk vim software-properties-common \
    python-software-properties moreutils incron \
    inotify-tools task-spooler

ADD ./mergepdf.sh /opt/mergepdf.sh
RUN chmod a+x /opt/mergepdf.sh
RUN echo "lockfile_dir = /srv/input" >> /etc/incron.conf

RUN adduser --disabled-password --gecos '' r && adduser r sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo r >> /etc/incron.allow
USER r

RUN cd /home/r && incrontab -l > mycron && echo '/srv/input IN_CREATE /opt/mergepdf.sh $#' >> mycron && incrontab mycron && rm mycron
USER root
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENV OCR_TIMEOUT=540
ENV FW_TIMEOUT=600
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/incrond","-n"]
