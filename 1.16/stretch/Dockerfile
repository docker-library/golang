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

ENV GOLANG_VERSION 1.16.1

RUN set -eux; \
	\
	dpkgArch="$(dpkg --print-architecture)"; \
	url=; \
	case "${dpkgArch##*-}" in \
		'amd64') \
			url='https://storage.googleapis.com/golang/go1.16.1.linux-amd64.tar.gz'; \
			sha256='3edc22f8332231c3ba8be246f184b736b8d28f06ce24f08168d8ecf052549769'; \
			;; \
		'armel') \
			export GOARCH='arm' GOARM='5' GOOS='linux'; \
			;; \
		'armhf') \
			url='https://storage.googleapis.com/golang/go1.16.1.linux-armv6l.tar.gz'; \
			sha256='c49e1680de0d72917e6a16423adcc0c57a86e6ec2324510ddeb4bff35e46ecb4'; \
			;; \
		'arm64') \
			url='https://storage.googleapis.com/golang/go1.16.1.linux-arm64.tar.gz'; \
			sha256='fa8a6034e51e5cceaa477027d44c2f9a2f1d9540e8ce881014c526c11290a180'; \
			;; \
		'i386') \
			url='https://storage.googleapis.com/golang/go1.16.1.linux-386.tar.gz'; \
			sha256='de050a1161fe450968e9db139f48685312657297065e81508ced7ca7cb61d913'; \
			;; \
		'mips64el') \
			export GOARCH='mips64le' GOOS='linux'; \
			;; \
		'ppc64el') \
			url='https://storage.googleapis.com/golang/go1.16.1.linux-ppc64le.tar.gz'; \
			sha256='5412da4f2cd5dd8d2292b187e9c03afa5ccc058abdfaf4c534f064bd96074d3a'; \
			;; \
		's390x') \
			url='https://storage.googleapis.com/golang/go1.16.1.linux-s390x.tar.gz'; \
			sha256='b5a0e661993702f4059f23038df399c9d7c88d11002f317907aac0423f769ebf'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$dpkgArch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	build=; \
	if [ -z "$url" ]; then \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
		build=1; \
		url='https://storage.googleapis.com/golang/go1.16.1.src.tar.gz'; \
		sha256='680a500cd8048750121677dd4dc055fdfd680ae83edc7ed60a4b927e466228eb'; \
		echo >&2; \
		echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; \
		echo >&2; \
	fi; \
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
	if [ -n "$build" ]; then \
		savedAptMark="$(apt-mark showmanual)"; \
		apt-get update; \
		apt-get install -y --no-install-recommends golang-go; \
		\
		( \
			cd /usr/local/go/src; \
# set GOROOT_BOOTSTRAP + GOHOST* such that we can build Go successfully
			export GOROOT_BOOTSTRAP="$(go env GOROOT)" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
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
