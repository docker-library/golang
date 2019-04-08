FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11.8

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='e32ab1c934b747999d04e8a550b97f4647f8b1b43e152de5650d4476bfd1d2e1' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='c5d4fd90242761c214124eedb0ffc35af52be19e7a4eb4006b036b5dcb422c87' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='68c42239d118b27f5e52a449f444c8a53e64a181b12d9ecbda14d0c3b765a5ee' ;; \
		i386) goRelArch='linux-386'; goRelSha256='e0e62a02516fa2197a2eb319a6957e7bd7007005a11b4da5c6650879999db899' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='4f0559832957c37022f771420902c1f19100c0a5b391c4957753c521a9eba56e' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='023928ee1d896af181c62acfd0a4e7bd713c8503a9b3b9aec745a3a830630e1b' ;; \
		*) goRelArch='src'; goRelSha256='ba18bf8daf89218f9f2d853b3a9bc117d0ac24d3c98dac3474ed9ff9bf8efead'; \
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
