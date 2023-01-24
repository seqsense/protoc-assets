FROM alpine:3.16

# Install interpreter languages and tools
RUN apk add --no-cache \
    libstdc++ \
    make \
    nodejs \
    py3-setuptools \
    python3 \
    ruby

# Install protobuf and grpcio
RUN apk add --no-cache \
    protoc

ARG GLIBC_VERSION=2.33-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
  && apk add --no-cache --force-overwrite glibc-${GLIBC_VERSION}.apk \
  && rm /etc/apk/keys/sgerrand.rsa.pub glibc-${GLIBC_VERSION}.apk

ENV GOPATH /go
ENV PATH $GOPATH/bin:/node_modules/.bin/:$PATH

COPY go.mod go.sum /go/src/github.com/seqsense/protoc-assets/

ARG GRPC_VERSION=1.51.1

RUN cd /go/src/github.com/seqsense/protoc-assets/ \
  && apk add --no-cache --virtual .builddeps \
    go \
  && go install google.golang.org/protobuf/cmd/protoc-gen-go \
  && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc \
  && apk del .builddeps

RUN apk add --no-cache --virtual .builddeps \
    py3-pip \
  && python3 -m pip install \
    "grpcio_tools<=${GRPC_VERSION}" \
  && apk del .builddeps

RUN apk add --no-cache --virtual .builddeps \
    npm \
  && npm install -g \
    "grpc-tools@<=${GRPC_VERSION}" \
  && apk del .builddeps

RUN gem install \
    grpc-tools --version="<=${GRPC_VERSION}"

ENV LD_LIBRARY_PATH=/usr/lib:/lib

WORKDIR /defs
