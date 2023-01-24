FROM alpine:3.16

# Install interpreter languages and tools
RUN apk add --no-cache \
    git \
    libstdc++ \
    make \
    nodejs \
    npm \
    py3-setuptools \
    python3 \
    ruby \
    ruby-etc

# Install protobuf and grpcio
RUN apk add --no-cache \
    protobuf \
    py3-grpcio \
    py3-protobuf \
    ruby-google-protobuf

ARG GLIBC_VERSION=2.33-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
  && apk add --no-cache --force-overwrite glibc-${GLIBC_VERSION}.apk \
  && rm /etc/apk/keys/sgerrand.rsa.pub glibc-${GLIBC_VERSION}.apk

ENV GOPATH /go
ENV PATH $GOPATH/bin:/node_modules/.bin/:$PATH

COPY go.mod go.sum /go/src/github.com/seqsense/protoc-assets/
RUN cd /go/src/github.com/seqsense/protoc-assets/ \
  && apk add --no-cache --virtual .builddeps go \
  && go install google.golang.org/protobuf/cmd/protoc-gen-go \
  && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc \
  && apk del .builddeps

RUN apk add --no-cache --virtual .builddeps \
    gcc \
    g++ \
    linux-headers \
    py3-pip \
    python3-dev \
    ruby-dev \
    ruby-irb \
    ruby-rdoc \
  && export GRPCIO_VERSION=$(pip3 show grpcio | grep '^Version:' | sed 's|^\S*:\s*||') \
  && export GRPC_PYTHON_BUILD_EXT_COMPILER_JOBS=$(echo -e "$(nproc)\n16" | sort | head -n1) \
  && python3 -m pip install \
    grpcio-tools==${GRPCIO_VERSION} \
  && npm install -g \
    google-protobuf \
    grpc-tools \
  && gem install \
    grpc:${GRPCIO_VERSION} \
    grpc-tools:${GRPCIO_VERSION} \
  && apk del .builddeps

ENV LD_LIBRARY_PATH=/usr/lib:/lib

WORKDIR /defs
