FROM alpine:3.4

RUN apk add --no-cache ca-certificates

RUN set -ex \
	&& apk add --no-cache go

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

COPY go-wrapper /usr/local/bin/
