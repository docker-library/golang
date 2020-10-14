#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.15.3

RUN set -eux; \
	\
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		'amd64') \
			arch='linux-amd64'; \
			url='https://storage.googleapis.com/golang/go1.15.3.linux-amd64.tar.gz'; \
			sha256='010a88df924a81ec21b293b5da8f9b11c176d27c0ee3962dc1738d2352d3c02d'; \
			;; \
		'armhf') \
			arch='linux-armv6l'; \
			url='https://storage.googleapis.com/golang/go1.15.3.linux-armv6l.tar.gz'; \
			sha256='aacb49968d08e222c83dea7307b4523c3ae498a5d2e91cd0e480ef3f198ffef6'; \
			;; \
		'arm64') \
			arch='linux-arm64'; \
			url='https://storage.googleapis.com/golang/go1.15.3.linux-arm64.tar.gz'; \
			sha256='b8b88a87ada918ef5189fa5938ef4c46a4f61952a34317612aaac705f4275f80'; \
			;; \
		'i386') \
			arch='linux-386'; \
			url='https://storage.googleapis.com/golang/go1.15.3.linux-386.tar.gz'; \
			sha256='e2f4f9ccfebd38b112fe84572af44bb2fa230d605fcec84def9498095c1bd6ce'; \
			;; \
		'ppc64el') \
			arch='linux-ppc64le'; \
			url='https://storage.googleapis.com/golang/go1.15.3.linux-ppc64le.tar.gz'; \
			sha256='ea420501f9dc4bb1f0db37bb91a7d4e1bb7607bc1865c3ca51ed802477c169ad'; \
			;; \
		's390x') \
			arch='linux-s390x'; \
			url='https://storage.googleapis.com/golang/go1.15.3.linux-s390x.tar.gz'; \
			sha256='098b256bdee92857270a23a47b396e403be378d4cf8331611038518c921de46d'; \
			;; \
		*) \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
			arch='src'; \
			url='https://storage.googleapis.com/golang/go1.15.3.src.tar.gz'; \
			sha256='896a602570e54c8cdfc2c1348abd4ffd1016758d0bd086ccd9787dbfc9b64888'; \
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
