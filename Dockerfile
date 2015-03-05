FROM tutum/curl:trusty
MAINTAINER Feng Honglin <hfeng@tutum.co>

ADD . /gopath/src/github.com/tutumcloud/image-cleanup

RUN apt-get update -y && \
    apt-get install --no-install-recommends -y -q git && \
    mkdir /goroot && \
    curl -s https://storage.googleapis.com/golang/go1.3.linux-amd64.tar.gz | tar xzf - -C /goroot --strip-components=1 && \ 
    export GOROOT=/goroot && \
    export GOPATH=/gopath && \
    export PATH=$PATH:/goroot/bin && \
    go get github.com/tutumcloud/image-cleanup && \
    cp /gopath/bin/* / && \
    rm -fr /goroot /gopath /var/lib/apt/lists && \
    apt-get autoremove -y git && \
    apt-get clean

ENV IMAGE_CLEAN_INTERVAL 1
ENV IMAGE_CLEAN_DELAYED 1800
ENV VOLUME_CLEAN_INTERVAL 1800
ENV IMAGE_LOCKED **None**

ADD run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
