FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='68a2297eb099d1a76097905a2ce334e3155004ec08cdea85f24527be3c48e856' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='931906d67cae1222f501e7be26e0ee73ba89420be0c4591925901cb9a4e156f0' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='e2a61328101eff3b9c1ba47ecfec5eb2fdc3eb35d8c27d505737ba98bfcb197b' ;; \
		i386) goRelArch='linux-386'; goRelSha256='519b3e6ae4db011b93b60e6fabb055773ae6448355b6909a6befef87e02d98f5' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='807b036bb058061b6090635e2a8612aaf301895dce70a773bbcd67fa1e57337c' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='b7122795910b70b68e4118d0d34685a30925f4dd861c065cf20b699a7783807a' ;; \
		*) goRelArch='src'; goRelSha256='3fc0b8b6101d42efd7da1da3029c0a13f22079c0c37ef9730209d8ec665bf122'; \
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
