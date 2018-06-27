FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11beta1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='df7fe096ffab5d331d35c6d038d2ec0426b45ce17f55a93037e371d3af9d4e6d' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='844ed9e34b118a9c2b069a18924a7879236929e08c887a92e5be1af5d701fb90' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='9c1795148e777c81ac3cb381e3ea970eea60f5db2323658c061e5c4382125dd4' ;; \
		i386) goRelArch='linux-386'; goRelSha256='a6e804652f58785b3dfe272d96b8206250210e7ba7bdcb1ffb726ab3753db4af' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='66529a525c0369d2b79ecd19f6d16444ed162c9bf88f7b37715520841c36de65' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='731b9e6ac0d4c9709297f0efc1a6455589b978d2ecc207184d3e5be07a130c9c' ;; \
		*) goRelArch='src'; goRelSha256='5955eeb8f45e02aa5357fc18e62f1fe6c1b19e0c50aba93b8b9d9ef13b862dda'; \
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
