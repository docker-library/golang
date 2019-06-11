FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11.11

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='2fd47b824d6e32154b0f6c8742d066d816667715763e06cebb710304b195c775' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='c2b882a5fbb3bac5c9cc6d65bfe17a5febfe0251a339fc059306bb825dec9b17' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='5ee39ea08e5d8c017658f36d0f969b17a44d49576214f4a00710f2d98bb773be' ;; \
		i386) goRelArch='linux-386'; goRelSha256='c711fe5025608e14bcd0efda9403e9b8f05cb4a53a125e296d639c10d280a65f' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='98ff7ff2367239e26745231aabeaf9d7e51c40b616bb9aa15d4376792ff581d1' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='d7471874ed396f72dd550c3593c9f42d5e3d38a2cca7658e669305bf9023e6c8' ;; \
		*) goRelArch='src'; goRelSha256='1fff7c33ef2522e6dfaf6ab96ec4c2a8b76d018aae6fc88ce2bd40f2202d0f8c'; \
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
