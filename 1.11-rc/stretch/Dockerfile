FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11rc1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='1a071f069982427b245aea736d3174e065a12e8481c34051c672d62a5ca59ca9' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='6f2c0a53850e7dcd2f1592eb51325fa5da20ee953512bebf1b0d3fb046874dc4' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='8a3d96e3e7604cf5390b7e318ff35112cdb13e0e44ddf0130659cefd196ab50e' ;; \
		i386) goRelArch='linux-386'; goRelSha256='afe8f516fbd0316981e70fc0dda8c67116837baaa0431ee2da47f4fee4614433' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='972e7b6bfecee780a9cd970100297b35bed4c82cacc2bd55d78428928b66683d' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='bd30adfb32de8c441fc0b12a9a9acbd5098a77ab77609269aed7ea4f8dd682ae' ;; \
		*) goRelArch='src'; goRelSha256='fcb8778ad5d1bb7f5bfd1564ba4107894011f1d65f69be9fa1e693f6b5143828'; \
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
