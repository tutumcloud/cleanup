FROM tutum/curl:trusty
MAINTAINER Feng Honglin <hfeng@tutum.co>

ENV DOCKER_VERSION 1.2.0
RUN curl -OL https://files.tutum.co/packages/docker/docker-${DOCKER_VERSION} &&\
    curl -OL https://files.tutum.co/packages/docker/docker-${DOCKER_VERSION}.md5 &&\
    md5sum docker-${DOCKER_VERSION} | diff - docker-${DOCKER_VERSION}.md5 &&\
    chmod +x docker-${DOCKER_VERSION} &&\
    mv docker-${DOCKER_VERSION} /usr/bin/docker

ENV CLEAN_PERIOD **None**
ENV DELAY_TIME **None**

ADD run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]
