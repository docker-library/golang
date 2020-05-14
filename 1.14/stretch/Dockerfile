FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.14.3

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='1c39eac4ae95781b066c144c58e45d6859652247f7515f0d2cba7be7d57d2226' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='b1c3a648c3c8877b98dfba1996dec604c8fb8899db07994b2dfd47b0063367c8' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='a7a593e2ee079d83a1943edcd1c9ed2dae7529666fce04de8c142fb61c7cdd3e' ;; \
		i386) goRelArch='linux-386'; goRelSha256='46f8c744788103e8aeceb12c7d71eb16a58fe43e7e4711055fa9ef4bae50bff7' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='329359e2b72839696e78b6c0a96fd939e28e7435d852f31107f68037dd5f7442' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='1aad312fc7fa85d663e8226237cc7519b2599b88a213098abc10de8e84d6cfab' ;; \
		*) goRelArch='src'; goRelSha256='93023778d4d1797b7bc6a53e86c3a9b150c923953225f8a48a2d5fabc971af56'; \
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
