FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13beta1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='dbd131c92f381a5bc5ca1f0cfd942cb8be7d537007b6f412b5be41ff38a7d0d9' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='77993f1dce5b4d080cbd06a4553e5e1c6caa7ad6817ea3c62254b89d6f079504' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='298a325d8eeba561a26312a9cdc821a96873c10fca7f48a7f98bbd8848bd8bd4' ;; \
		i386) goRelArch='linux-386'; goRelSha256='38039e4f7b6eea8f55e91d90607150d5d397f9063c06445c45009dd1e6dba8cc' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='0f3c5c7b7956911ed8d1fc4e9dbeb2584d0be695c5c15b528422e3bb2d5989f0' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='877065ac7d1729e5de1bbfe1e712788bf9dee5613a5502cf0ba76e65c2521b26' ;; \
		*) goRelArch='src'; goRelSha256='e8a7c504cd6775b8a6af101158b8871455918c9a61162f0180f7a9f118dc4102'; \
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
