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

ENV GOLANG_VERSION 1.14.7

RUN set -eux; \
	\
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		'amd64') \
			arch='linux-amd64'; \
			url='https://storage.googleapis.com/golang/go1.14.7.linux-amd64.tar.gz'; \
			sha256='4a7fa60f323ee1416a4b1425aefc37ea359e9d64df19c326a58953a97ad41ea5'; \
			;; \
		'armhf') \
			arch='linux-armv6l'; \
			url='https://storage.googleapis.com/golang/go1.14.7.linux-armv6l.tar.gz'; \
			sha256='6079eb82bcf24b33dda0e32777c7fdddcc3b1ec70e374308cc8311562449b107'; \
			;; \
		'arm64') \
			arch='linux-arm64'; \
			url='https://storage.googleapis.com/golang/go1.14.7.linux-arm64.tar.gz'; \
			sha256='fe5b6f6e441f3cb7b53ebf1a010bbebcb720ac98124984cfe2e51d72b8a58c71'; \
			;; \
		'i386') \
			arch='linux-386'; \
			url='https://storage.googleapis.com/golang/go1.14.7.linux-386.tar.gz'; \
			sha256='2f5793f10bb6b08eedecd376aa3d594e10193c6b5cf198ada46200259ff76547'; \
			;; \
		'ppc64el') \
			arch='linux-ppc64le'; \
			url='https://storage.googleapis.com/golang/go1.14.7.linux-ppc64le.tar.gz'; \
			sha256='bd1f12a2271a6d1689bcf3ec01d123c81cbaca5d16c3f7df294a2d725ac4d3d1'; \
			;; \
		's390x') \
			arch='linux-s390x'; \
			url='https://storage.googleapis.com/golang/go1.14.7.linux-s390x.tar.gz'; \
			sha256='ea570b3caa0c271da440f568ab646cfea80d712c51fb4d08189bb66bd5eb949c'; \
			;; \
		*) \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
			arch='src'; \
			url='https://storage.googleapis.com/golang/go1.14.7.src.tar.gz'; \
			sha256='064392433563660c73186991c0a315787688e7c38a561e26647686f89b6c30e3'; \
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
