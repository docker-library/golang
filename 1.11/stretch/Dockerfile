FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11.6

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='4e1864282d8d20010d6385a12a1e35641783a380a7c57907bfb46a5499c5eb49' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='62597fe72f1170cbb939958823555a701510e00362eb8a10b7ace6e59c8e7e6e' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='29f64505cea47c57a46e2c8001ecf8d0c01cbf1ec86de96f4e3126b94a12ebb7' ;; \
		i386) goRelArch='linux-386'; goRelSha256='7d90e484bb92e68648c1a7b6b1790e97af33718bae457d2ee02ee5d1dd0ce2b7' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='43d7cc7d3cdc1e57af33a13296b48713735f55e25aa655187afb19a707143c77' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='c7f83fa5975a8f11641962bad79f89a7e17a6580d0d21ca828733dc0cfe470f7' ;; \
		*) goRelArch='src'; goRelSha256='a96da1425dcbec094736033a8a416316547f8100ab4b72c31d4824d761d3e133'; \
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
