FROM ubuntu:trusty
MAINTAINER Feng Honglin <hfeng@tutum.co>

ENV CLEAN_PERIOD **None**
ENV DELAY_TIME **None**
ENV UNUSED_VOLUME_TIME **None**

ADD run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]
