FROM ubuntu:20.04

LABEL version="2020.11.24"
LABEL maintainer="AG"

ENV TZ=Europe/Amsterdam
ENV FW_TIMEOUT=60

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y pdftk incron 

ADD ./mergepdf.sh /opt/mergepdf.sh
RUN chmod a+x /opt/mergepdf.sh
RUN echo "lockfile_dir = /srv/input" >> /etc/incron.conf

RUN echo root >> /etc/incron.allow
RUN cd /home && incrontab -l > mycron && echo '/srv/input IN_CREATE /opt/mergepdf.sh $@/$#' >> mycron && incrontab mycron && rm mycron

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/incrond","-n"]
