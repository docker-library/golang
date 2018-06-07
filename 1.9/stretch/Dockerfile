FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.9.7

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='88573008f4f6233b81f81d8ccf92234b4f67238df0f0ab173d75a302a1f3d6ee' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='83b165d617807d636d2cfe07f34920ab6e5374a07ab02d60edcaec008de608ee' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='68f48c29f93e4c69bbbdb335f473d666b9f8791643f4003ef45283a968b41f86' ;; \
		i386) goRelArch='linux-386'; goRelSha256='c689fdb0b4f4530e48b44a3e591e53660fcbc97c3757ff9c3028adadabcf8378' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='66cc2b9d591c8ef5adc4c4454f871546b0bab6be1dcbd151c2881729884fbbdd' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='7148ba7bc6f40b342d35a28b0cc43dd8f2b2acd7fb3e8891bc95b0f783bc8c9f' ;; \
		*) goRelArch='src'; goRelSha256='582814fa45e8ecb0859a208e517b48aa0ad951e3b36c7fff203d834e0ef27722'; \
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
