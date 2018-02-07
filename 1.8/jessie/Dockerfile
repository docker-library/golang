FROM buildpack-deps:jessie-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.8.7

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='de32e8db3dc030e1448a6ca52d87a1e04ad31c6b212007616cfcc87beb0e4d60' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='7aa455a8ddec569e778b23166102bb26f1bdb3ad5feec15b688654a10a9d3d2a' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='804c2e73eca5ce309f2947aaf437fce9f67463b4fb9484f47c95b632d4eeabf6' ;; \
		i386) goRelArch='linux-386'; goRelSha256='3afab0048a44f66c4132f1fe26d3301fa4c51b47e7176c2d3f311c49d9aa74d6' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='588527ed410653318188b45eb27de098bdb12f95060a648e14587b28bf1761d9' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='a4dc8ceec71e6f22c10e5781a89dec91e9a1819f56822ac38a54de1700df1226' ;; \
		*) goRelArch='src'; goRelSha256='5911e751807eebbc1980dad4305ef5492b96d6cd720bf93cbcefa86e1c195f9e'; \
			echo >&2; echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; echo >&2 ;; \
	esac; \
	\
	url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz"; \
	wget -O go.tgz "$url"; \
	echo "${goRelSha256} *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ "$goRelArch" = 'src' ]; then \
		echo >&2; \
		echo >&2 'error: UNIMPLEMENTED'; \
		echo >&2 'TODO install golang-any from jessie-backports for GOROOT_BOOTSTRAP (and uninstall after build)'; \
		echo >&2; \
		exit 1; \
	fi; \
	\
	export PATH="/usr/local/go/bin:$PATH"; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

COPY go-wrapper /usr/local/bin/
