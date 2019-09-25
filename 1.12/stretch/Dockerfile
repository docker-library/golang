FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.10

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='aaa84147433aed24e70b31da369bb6ca2859464a45de47c2a5023d8573412f6b' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='b20a897e3a078637a91e8c91ff69a27bcefea7384a0019e56fbfd21f8170fe6b' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='d45d1eebe10a33a3d850cafcefd45200091a9ddb880857135307ee0de9424d24' ;; \
		i386) goRelArch='linux-386'; goRelSha256='863ad8abc9a9a18a9d55e2a3a2c68046ae57ccd34c2fa0159b70d015957391d6' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='9c5787aeca109c6f90f0ef82328f9ec8d54cf5a4a51d23bfedfc440e92649f9d' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='a8ab50d133db183d9afa304f79c9e994c9208aec9d1bf14b04cd2bda478f406a' ;; \
		*) goRelArch='src'; goRelSha256='f56e48fce80646d3c94dcf36d3e3f490f6d541a92070ad409b87b6bbb9da3954'; \
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
