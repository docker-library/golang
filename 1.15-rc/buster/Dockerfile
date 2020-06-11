FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.15beta1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='11814b7475680a09720f3de32c66bca135289c8d528b2e1132b0ce56b3d9d6d7' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='d4da5c06097be8d14aeeb45bf8440a05c82e93e6de26063a147a31ed1d901ebc' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='2648b7d08fe74d0486ec82b3b539d15f3dd63bb34d79e7e57bebc3e5d06b5a38' ;; \
		i386) goRelArch='linux-386'; goRelSha256='83d732a3961006e058f44c9672fde93dbea3d1c3d69e8807d135eeaf21fb80c8' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='33f7bed5ee9d4a0343dc90a5aa4ec7a1db755d0749b624618c15178fd8df4420' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='493b4449e68d0deba559e3f23f611310467e4c70d30b3605ff06852f14477457' ;; \
		*) goRelArch='src'; goRelSha256='78cda84d4217ae0fdb8f87848474be28644bdc1aa16579055f852999a4793ac0'; \
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
