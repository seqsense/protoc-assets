# syntax = docker/dockerfile:1

FROM alpine:3.22

# Install interpreter languages and tools
RUN --mount=type=cache,target=/etc/apk/cache,id=apk \
  apk add --no-cache \
    grpc-plugins \
    libstdc++ \
    nodejs \
    protobuf-dev \
    protoc \
    py3-setuptools \
    python3 \
    ruby \
  && echo "common $(protoc --version)" >> /versions

ARG GLIBC_VERSION=2.33-r0
RUN  --mount=type=cache,target=/etc/apk/cache,id=apk \
  wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
  && apk add --no-cache --force-overwrite glibc-${GLIBC_VERSION}.apk \
  && rm /etc/apk/keys/sgerrand.rsa.pub glibc-${GLIBC_VERSION}.apk

ENV \
  GEM_HOME=/usr/local \
  GOPATH=/go \
  LD_LIBRARY_PATH=/usr/lib:/lib \
  PATH=/go/bin:/node_modules/.bin/:$PATH

COPY go.mod go.sum /go/src/github.com/seqsense/protoc-assets/
RUN  --mount=type=cache,target=/etc/apk/cache,id=apk \
  cd /go/src/github.com/seqsense/protoc-assets/ \
  && apk add --no-cache --virtual .builddeps \
    go \
  && go install google.golang.org/protobuf/cmd/protoc-gen-go \
  && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc \
  && go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
  && go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
  && mkdir -p /protos/grpc-gateway \
  && cp -r /go/pkg/mod/github.com/grpc-ecosystem/grpc-gateway/v2@*/protoc-gen-openapiv2 /protos/grpc-gateway/ \
  && echo "go $(protoc-gen-go --version)" >> /versions \
  && echo "go $(protoc-gen-go-grpc --version)" >> /versions \
  && echo "go $(protoc-gen-openapiv2 --version)" >> /versions \
  && apk del .builddeps

COPY package.json package-lock.json /
RUN  --mount=type=cache,target=/etc/apk/cache,id=apk \
  apk add --no-cache --virtual .builddeps \
    npm \
  && npm install \
  && echo "node grpc-tools $(npm view grpc-tools version)" >> /versions \
  && apk del .builddeps

COPY requirements.txt /
RUN  --mount=type=cache,target=/etc/apk/cache,id=apk \
  apk add --no-cache --virtual .builddeps \
    py3-pip \
  && python3 -m pip install --break-system-packages -r requirements.txt \
  && python3 -m pip show grpcio_tools \
    | sed -n 's/^Version: \(.*\)$/python grpcio_tools \1/p' >> /versions \
  && apk del .builddeps

COPY Gemfile Gemfile.lock /
RUN  --mount=type=cache,target=/etc/apk/cache,id=apk \
  apk add --no-cache --virtual .builddeps \
    ruby-bundler \
  && bundle install \
  && bundle show grpc-tools \
    | sed -n 's|^/.*/grpc-tools-\(.*\)$|ruby grpc-tools \1|p'>> /versions \
  && apk del .builddeps

RUN wget https://github.com/googleapis/googleapis/archive/refs/heads/master.tar.gz -O /tmp/googleapis.tar.gz \
  && mkdir -p /protos/googleapis \
  && tar xzfv /tmp/googleapis.tar.gz -C /protos/googleapis --strip-components 1 googleapis-master \
  && rm -rf /tmp/googleapis.tar.gz

WORKDIR /defs
