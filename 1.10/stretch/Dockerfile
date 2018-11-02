FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.10.5

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='a035d9beda8341b645d3f45a1b620cf2d8fb0c5eb409be36b389c0fd384ecc3a' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='1d864a6d0ec599de9112c8354dcaaa886b4df928757966939402598e9bd9c238' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='b4c16fcee18bc79de2fa4776c8d0f9bc164ddfc32101e96fe1da83ebe881e3df' ;; \
		i386) goRelArch='linux-386'; goRelSha256='bc1bd42405a551ba7ac86b79b9d23a5635f21de53caf684acd8bf5dfee8bef5d' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='8fc13736d383312710249b24adf05af59ff14dacb73d9bd715ff463bc89c5c5f' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='e90269495fab7ef99aea6937caf7a049896b2dc7b181456f80a506e69a8b57fc' ;; \
		*) goRelArch='src'; goRelSha256='f0a3ed5c775f39a970d4937c64b3b178992e23a5df57ae56a59a1c99253094f4'; \
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
