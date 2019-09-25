FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13.1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='94f874037b82ea5353f4061e543681a0e79657f787437974214629af8407d124' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='7c75d4002321ea4a066dfe13f6dd5168076e9a231317c5afd55e78b86f478e37' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='8af8787b7c2a3c0eb3f20f872577fcb6c36098bf725c59c4923921443084c807' ;; \
		i386) goRelArch='linux-386'; goRelSha256='4bf7a961fda7ad892b8824002036de8c0f290df05df2e8f11252d1f8c77dcd8f' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='72422c68dbed013ee321a05dbb97d9c8d6b2c75f347de707138c2c748fc4aceb' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='5f0859ae1037ad7af6cdb6d16f638de908fd9de044d463eeab92b9578d4c7c75' ;; \
		*) goRelArch='src'; goRelSha256='81f154e69544b9fa92b1475ff5f11e64270260d46e7e36c34aafc8bc96209358'; \
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
