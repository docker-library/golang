FROM buildpack-deps:jessie-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.8.2

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='031035eab11903237e02007fc69c085bd4769ff2e2aa5e9af427ddaed3d37e2b' ;; \
		i386) goRelArch='linux-386'; goRelSha256='00bc94606610bf25c660d6106fa8e61cca6a276c046f3ceb9091053e99ceebe9' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='f091afb86501191270e14a653a056e8e7635e18a72e43cfbd13093b2482ca7a8' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='a1942b2833e7d2685d7dbb7ac81c66125c351f24c7f006e8ae4a4283905257d1' ;; \
		amd64) goRelArch='linux-amd64'; goRelSha256='5477d6c9a4f96fa120847fafa88319d7b56b5d5068e41c3587eebe248b939be7' ;; \
		*) goRelArch='src'; goRelSha256='e10401faaa8ae29dbe87349c1814b07b1903d453f822215d7b274bbc335cbf79'; \
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
