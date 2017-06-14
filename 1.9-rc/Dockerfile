FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.9beta1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='85719a2c704ad1352052e185c760d7c65b9d8a18b491287a7e5f6775ccc27d3b' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='26eb517a72bd0e9b1bc7f24ea52ded1991c72e09cd876c9747641c193c734cdc' ;; \
		i386) goRelArch='linux-386'; goRelSha256='af9fbef65761c03ee101eb23e1d1a673734c82b50546fed95710a6b04fe52995' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='8708e49428d493d07ce71f09b31b720ff8c8fe469698cd5e9f44f088c1ef75da' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='c16f86dd69bf282ca4bba60a6449130c5c0d988917d0c1f9d62a5e2fd5191a83' ;; \
		*) goRelArch='src'; goRelSha256='e42dbd2071aadb28a4d293225b04b6b4215a35a7f04417a0e47ffa38f81d642d'; \
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

COPY go-wrapper /usr/local/bin/
