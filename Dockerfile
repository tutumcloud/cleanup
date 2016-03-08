FROM alpine
MAINTAINER Feng Honglin <hfeng@tutum.co>

ENV DOCKER_ROOT_DIR /var/lib/docker/
ENV IMAGE_CLEAN_INTERVAL 1
ENV IMAGE_CLEAN_DELAYED 1800
ENV IMAGE_LOCKED **None**

ADD /cleanup /cleanup
ADD run.sh /run.sh

CMD ["/run.sh"]
