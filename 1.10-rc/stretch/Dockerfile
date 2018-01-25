FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.10rc1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='c10d3cc7760bf3799037bd39027bbffdc568aea21d6fe60fe833373289c7b7c6' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='2c1ed86e3cbf9d9866333b73cee96a0cd0b8c73654f4705088caa64eb5a624d4' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='3a749faf38e80025b832dae250442ddc86d5bc353d752c781ea632e904922ff1' ;; \
		i386) goRelArch='linux-386'; goRelSha256='03a98cc12b65dde36ed9561fa23530bcf5fa7ed85596aa74f2380f686fcbe928' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='f482c7d6193c23d36657f8f026a74222c82eeb443331c38bbf3493d971144988' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='a20d4077c0bb1d58710e48478ba0042950cf282f6ef1593aea4ac6e66265d22c' ;; \
		*) goRelArch='src'; goRelSha256='743e97c856067f12fb39f1323d6e9956fb5f3339f0691d8749ecea553548ab03'; \
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
