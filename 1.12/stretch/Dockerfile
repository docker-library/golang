FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.4

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='d7d1f1f88ddfe55840712dc1747f37a790cbcaa448f6c9cf51bbe10aa65442f5' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='c43457b6d89016e9b79b92823003fd7858fb02aea22b335cfd204e0b5be71d92' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='b7d7b4319b2d86a2ed20cef3b47aa23f0c97612b469178deecd021610f6917df' ;; \
		i386) goRelArch='linux-386'; goRelSha256='eba5c51f657c1b05d5930475d1723758cd86db74499125ab48f0f9d1863845f7' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='51642f3cd6ef9af6c4a092c2929e4fb478f102fe949921bd77ecd6905952c216' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='0aab0f368c090da71f52531ebac977cc7396b692145acee557b3f9500b42467a' ;; \
		*) goRelArch='src'; goRelSha256='4affc3e610cd8182c47abbc5b0c0e4e3c6a2b945b55aaa2ba952964ad9df1467'; \
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
