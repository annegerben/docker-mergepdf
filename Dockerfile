FROM ubuntu:18.04

LABEL version="1.0.5"
LABEL maintainer="n/a"

RUN apt-get update && apt-get -y install build-essential unzip \
    wget vim software-properties-common \
    moreutils incron \
    inotify-tools task-spooler 

RUN add-apt-repository -y ppa:malteworld/ppa
RUN apt install -y pdftk
ADD ./mergepdf.sh /opt/mergepdf.sh
ADD ./rename_odd.sh /opt/rename_odd.sh
ADD ./rename_even.sh /opt/rename_even.sh
RUN chmod a+x /opt/mergepdf.sh
RUN chmod a+x /opt/rename_odd.sh
RUN chmod a+x /opt/rename_even.sh
RUN echo "lockfile_dir = /srv" >> /etc/incron.conf

#RUN adduser --disabled-password --gecos '' r && adduser r sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo root >> /etc/incron.allow
#USER r

RUN cd /home && incrontab -l > mycron && echo '/srv/input IN_MOVED_TO /opt/mergepdf.sh $#' > mycron && echo '/srv/odd IN_MOVED_TO /opt/rename_odd.sh $#' >> mycron && echo '/srv/even IN_MOVED_TO /opt/rename_even.sh $#' >> mycron && incrontab mycron && rm mycron
#USER root
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
COPY rename_odd.sh /
RUN chmod +x /rename_odd.sh
COPY rename_even.sh /
RUN chmod +x /rename_even.sh
ENV OCR_TIMEOUT=120
ENV FW_TIMEOUT=60
ENV TZ=EUROPE/AMSTERDAM
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/incrond","-n"]
