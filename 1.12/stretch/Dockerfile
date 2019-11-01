FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.13

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='da036454cb3353f9f507f0ceed4048feac611065e4e1818b434365eb32ac9bdc' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='bf061cc3d4951e07904496b5c3d6c82419309d24634835522d786673a3f5438f' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='dcfcb3785292c98f7a75c2276169dfe2d445c19f8ffe1d40b3f7b8f59712d361' ;; \
		i386) goRelArch='linux-386'; goRelSha256='fafcb585591557b7b16d9b22dec4654193d205cf444b1810ab2988f658585e23' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='77056264abcf5444ed0d9ab7552552ae2145ca8fb6c39d33db3c735eaf3f42d2' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='8ef1ffbe7d0e944a52aadd529fc88fd6a2303ec67ee7eeb906712ca38ada0c91' ;; \
		*) goRelArch='src'; goRelSha256='5383d3b8db4baa48284ffcb14606d9cad6f03e9db843fa6d835b94d63cccf5a7'; \
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
