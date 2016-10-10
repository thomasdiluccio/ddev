FROM golang:1.7-alpine
ENV DRUD_BUILD_DIR $GOPATH/src/github.com/drud/bootstrap/cli
ENV CGO_ENABLED=0
ENV GOOS=linux

RUN apk add  --update bzr git ca-certificates wget gcc abuild binutils binutils-doc gcc-doc cmake cmake-doc bash musl-dev openssl \
    && mkdir -p $DRUD_BUILD_DIR

RUN echo "http://dl-6.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    apk add docker

RUN apk add python \
    python-dev \
    py-pip \
    build-base \
    openssh

RUN pip install docker-compose

WORKDIR $DRUD_BUILD_DIR

ADD . $DRUD_BUILD_DIR


ADD start.sh /

RUN chmod ugo+x /start.sh \
&& go build -a -installsuffix cgo -ldflags '-w' -o $GOPATH/bin/drud  ./main.go

# We repeat this as a cmd so you can volume mount in a bin directory to generate a binary.
ENTRYPOINT ["/start.sh"]
CMD ["go", "build", "-a", "-installsuffix", "cgo", "-ldflags", "'-w'", "-o", "/go/bin/drud", "./main.go"]