FROM ubuntu:20.04

LABEL version="1.0.6"
LABEL maintainer="annegerben(a)vanassen.eu"

ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y build-essential unzip \
    wget pdftk vim software-properties-common \
    moreutils incron \
    inotify-tools task-spooler 

ADD ./mergepdf.sh /opt/mergepdf.sh
ADD ./rename_odd.sh /opt/rename_odd.sh
ADD ./rename_even.sh /opt/rename_even.sh
RUN chmod a+x /opt/mergepdf.sh
RUN chmod a+x /opt/rename_odd.sh
RUN chmod a+x /opt/rename_even.sh
RUN echo "lockfile_dir = /srv" >> /etc/incron.conf

RUN echo root >> /etc/incron.allow



RUN cd /home && incrontab -l > mycron && echo '/srv/input IN_CREATE IN_MOVED_TO /opt/mergepdf.sh $#' >> mycron && incrontab mycron && rm mycron
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENV TZ=EUROPE/AMSTERDAM
ENV OCR_TIMEOUT=120
ENV FW_TIMEOUT=60

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/incrond","-n"]
