FROM debian:wheezy

# SCMs for "go get", gcc for cgo
RUN apt-get update && apt-get install -y \
		ca-certificates curl gcc libc6-dev \
		bzr git mercurial make \
		--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.2.1

RUN curl -sSL https://go.googlecode.com/files/go$GOLANG_VERSION.src.tar.gz \
		| tar -v -C /usr/src -xz

RUN cd /usr/src/go/src && ./make.bash --no-clean 2>&1

ENV PATH /usr/src/go/bin:$PATH

RUN mkdir -p /go/src
ENV GOPATH /go
ENV PATH /go/bin:$PATH
WORKDIR /go

COPY go-wrapper /usr/local/bin/
