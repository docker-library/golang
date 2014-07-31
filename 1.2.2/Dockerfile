FROM debian:wheezy

# Go building deps and SCMs for "go get"
RUN apt-get update && apt-get install -y \
		build-essential ca-certificates curl \
		bzr git mercurial \
		--no-install-recommends

RUN curl -sSL http://golang.org/dl/go1.2.2.src.tar.gz \
	| tar -v -C /usr/src -xz
WORKDIR /usr/src/go

RUN cd src && ./make.bash --no-clean 2>&1

ENV PATH /usr/src/go/bin:$PATH

RUN mkdir -p /go/src
ENV GOPATH /go
ENV PATH /go/bin:$PATH
WORKDIR /go
