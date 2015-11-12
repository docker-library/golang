FROM alpine:3.2

ENV GOLANG_VERSION 1.4.3
ENV GOLANG_SRC_URL https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz
ENV GOLANG_SRC_SHA1 486db10dc571a55c8d795365070f66d343458c48

RUN set -ex \
	&& buildDeps='bash ca-certificates gcc musl-dev openssl' \
	&& apk add --update $buildDeps \
	&& rm -rf /var/cache/apk/* \
	\
	&& wget -q "$GOLANG_SRC_URL" -O golang.tar.gz \
	&& echo "$GOLANG_SRC_SHA1  golang.tar.gz" | sha1sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz \
	&& cd /usr/local/go/src \
	&& ./make.bash \
	\
	&& apk del $buildDeps

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
