#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.14.15

RUN set -eux; \
	\
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		'amd64') \
			arch='linux-amd64'; \
			url='https://storage.googleapis.com/golang/go1.14.15.linux-amd64.tar.gz'; \
			sha256='c64a57b374a81f7cf1408d2c410a28c6f142414f1ffa9d1062de1d653b0ae0d6'; \
			;; \
		'armhf') \
			arch='linux-armv6l'; \
			url='https://storage.googleapis.com/golang/go1.14.15.linux-armv6l.tar.gz'; \
			sha256='a63960d9b9c14954e299ffe060c0574ffb91ab810837da5941853b664d0652da'; \
			;; \
		'arm64') \
			arch='linux-arm64'; \
			url='https://storage.googleapis.com/golang/go1.14.15.linux-arm64.tar.gz'; \
			sha256='4d964166a189c22032521c63935437c304bb7f01673b196898cff525897a1c27'; \
			;; \
		'i386') \
			arch='linux-386'; \
			url='https://storage.googleapis.com/golang/go1.14.15.linux-386.tar.gz'; \
			sha256='cab962eaf954378bbb5b24f703baf3b471e9690a109082dd688593fbb6f9008e'; \
			;; \
		'ppc64el') \
			arch='linux-ppc64le'; \
			url='https://storage.googleapis.com/golang/go1.14.15.linux-ppc64le.tar.gz'; \
			sha256='64d82004270bcd00948dbed9f1a123ef844ceb7633e6a87a5ca7ef8bdf59cfc1'; \
			;; \
		's390x') \
			arch='linux-s390x'; \
			url='https://storage.googleapis.com/golang/go1.14.15.linux-s390x.tar.gz'; \
			sha256='8e121c947ec531628d37ad0292623f22c8f9fecac6067192b5cce34b36cedd79'; \
			;; \
		*) \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
			arch='src'; \
			url='https://storage.googleapis.com/golang/go1.14.15.src.tar.gz'; \
			sha256='7ed13b2209e54a451835997f78035530b331c5b6943cdcd68a3d815fdc009149'; \
			echo >&2; \
			echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; \
			echo >&2; \
			;; \
	esac; \
	\
	wget -O go.tgz.asc "$url.asc" --progress=dot:giga; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum --strict --check -; \
	\
# https://github.com/golang/go/issues/14739#issuecomment-324767697
	export GNUPGHOME="$(mktemp -d)"; \
# https://www.google.com/linuxrepositories/
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC EC91 7721 F63B D38B 4796'; \
	gpg --batch --verify go.tgz.asc go.tgz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" go.tgz.asc; \
	\
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ "$arch" = 'src' ]; then \
		savedAptMark="$(apt-mark showmanual)"; \
		apt-get update; \
		apt-get install -y --no-install-recommends golang-go; \
		\
		goEnv="$(go env | sed -rn -e '/^GO(OS|ARCH|ARM|386)=/s//export \0/p')"; \
		eval "$goEnv"; \
		[ -n "$GOOS" ]; \
		[ -n "$GOARCH" ]; \
		( \
			cd /usr/local/go/src; \
			./make.bash; \
		); \
		\
		apt-mark auto '.*' > /dev/null; \
		apt-mark manual $savedAptMark > /dev/null; \
		apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
		rm -rf /var/lib/apt/lists/*; \
		\
# pre-compile the standard library, just like the official binary release tarballs do
		go install std; \
# go install: -race is only supported on linux/amd64, linux/ppc64le, linux/arm64, freebsd/amd64, netbsd/amd64, darwin/amd64 and windows/amd64
#		go install -race std; \
		\
# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain
		rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
		; \
	fi; \
	\
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
