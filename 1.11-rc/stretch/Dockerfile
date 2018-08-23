FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11rc2

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='7d3fc1dec64b056cbd22ffd80bb9733725c1296aabfd58cc92bab8a5c6560e03' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='502272db03f6c6883fec5c9e17730b469966d87f9c07e6a306637ddf0fe83526' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='5b160c1ea4c863f82d5d9ebad51edc08f5a5ecf368d315c8aff2c99420fb075c' ;; \
		i386) goRelArch='linux-386'; goRelSha256='a1982f3af77875c1e8f7c5056ce815236a62902472aceb95fc66e47555d88010' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='d58470aa1e79282b35f7b61cb8d1ac3f0cbecd6d837076795a30003c947feef2' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='85f56c3847eb1ba6b1faf14869671b6d7c31d5ef0082dc1c32a2c53a5e831c76' ;; \
		*) goRelArch='src'; goRelSha256='5947695c5289ddb6ddc22d01d498b94ddb86bb6775593d772156c4e72a482516'; \
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
