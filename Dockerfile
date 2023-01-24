FROM alpine:3.16

# Install interpreter languages and tools
RUN apk add --no-cache \
    libstdc++ \
    nodejs \
    protoc \
    py3-setuptools \
    python3 \
    ruby

ARG GLIBC_VERSION=2.33-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
  && apk add --no-cache --force-overwrite glibc-${GLIBC_VERSION}.apk \
  && rm /etc/apk/keys/sgerrand.rsa.pub glibc-${GLIBC_VERSION}.apk

ENV \
  GEM_HOME=/usr/local \
  GOPATH=/go \
  LD_LIBRARY_PATH=/usr/lib:/lib \
  PATH=/go/bin:/node_modules/.bin/:$PATH

COPY go.mod go.sum /go/src/github.com/seqsense/protoc-assets/
RUN cd /go/src/github.com/seqsense/protoc-assets/ \
  && apk add --no-cache --virtual .builddeps \
    go \
  && go install google.golang.org/protobuf/cmd/protoc-gen-go \
  && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc \
  && apk del .builddeps

COPY package.json package-lock.json /
RUN apk add --no-cache --virtual .builddeps \
    npm \
  && npm install \
  && apk del .builddeps

COPY requirements.txt /
RUN apk add --no-cache --virtual .builddeps \
    py3-pip \
  && python3 -m pip install -r requirements.txt \
  && apk del .builddeps

COPY Gemfile Gemfile.lock /
RUN apk add --no-cache --virtual .builddeps \
    ruby-bundler \
  && bundle install \
  && apk del .builddeps

WORKDIR /defs
