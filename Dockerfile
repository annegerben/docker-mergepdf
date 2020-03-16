FROM ubuntu:18.04

LABEL version="1.0.4"
LABEL maintainer="n/a"

RUN apt-get update && apt-get -y install build-essential unzip \
    wget vim software-properties-common \
    moreutils incron \
    inotify-tools task-spooler

RUN add-apt-repository -y ppa:malteworld/ppa
RUN apt install -y pdftk

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
