FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12beta2

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='9e4884b46a72e0558187a8af6e8733e039432df1b755f14b361f18b63fa5a63e' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='d41674dda2e33a539929a980c7ba8d68c90c8aabcb138b65a2dc36704af02ace' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='77d80484e455ad65aa0778aa82391c02ded01a37ee65f7887167dc03a6ef3251' ;; \
		i386) goRelArch='linux-386'; goRelSha256='ffe0d1c92473b2fd653e399c1ddb11535b9666f22b6ae5653bd1fb4f84534c46' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='a1701e3c216c970a833248d6e5df5f2c27c6103e8e3bde34c5c3c25e839e87f9' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='bb4ea794a8fa459ad596c03b08fba9de647c62369c74f5daf21a6bae8c855b11' ;; \
		*) goRelArch='src'; goRelSha256='fd3f4e1860ac59d647c22a2c1589fcf4a96c02bbbfef1ca1ea44bc25cf62a490'; \
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
