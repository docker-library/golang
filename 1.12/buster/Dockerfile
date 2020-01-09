FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.15

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='61068419f3d3fcd3cc415c352c4a93d6ae0e723ac18a22ac572b4904d78b5a4c' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='3a36d168bf80c780694bf25d6cb2ed0dbb6d4bc29b1c82bb29e819d9dbe6347b' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='cff1a28f0b207dd54230bf822cdcfbcc7cd411261a9366616a05a1fa1fbeedd3' ;; \
		i386) goRelArch='linux-386'; goRelSha256='608c9fb90b2b35f7b4e4b110a9c6919d8902311388c6309487b5f77aed9d2b74' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='4fe9ce71a6cd9acd56f0e898dd87d95ed9bc83a6a5be0863e9b5b646e05eee05' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='a02061245a738bc80c645251cddd7a22c1ea9fee0726d5caf5da7645dea3787e' ;; \
		*) goRelArch='src'; goRelSha256='8aba74417e527524ad5724e6e6c21016795d1017692db76d1b0851c6bdec84c3'; \
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
