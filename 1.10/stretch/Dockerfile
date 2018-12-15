FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.10.7

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='1aabe10919048822f3bb1865f7a22f8b78387a12c03cd573101594bc8fb33579' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='1f81c995f829c8fc7def4d0cc1bde63cac1834386e6f650f2cd7be56ab5e8b98' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='cb5a274f7c8f6186957e4503e724dda8aeffe84b76a146748c55ea5bb22d9ae4' ;; \
		i386) goRelArch='linux-386'; goRelSha256='55cd25e550cb8ce8250dbc9eda56b9c10b3097c7f6beed45066fbaaf8c6c1ebd' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='11279ffebfcfa875b0552839d428cc72e2056e68681286429b57173c0da91fb4' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='e0d7802029ed8d2720a2b27ec1816e71cb29f818380abb8b449080e97547881e' ;; \
		*) goRelArch='src'; goRelSha256='b84a0d7c90789f3a2ec5349dbe7419efb81f1fac9289b6f60df86bd919bd4447'; \
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
