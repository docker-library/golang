FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.11

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='2c5960292da8b747d83f171a28a04116b2977e809169c344268c893e4cf0a857' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='895766c9c1d1a32e9e0e7ea2f9fac6f33df0397954564c05b56ecdc58605fd1e' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='a05361badb95f6cc5724e32f59b0f33048dfca63b539cf2bd8ab77fa4f2ba923' ;; \
		i386) goRelArch='linux-386'; goRelSha256='9d979c489471c5ec9b9cd6b0922f061b2dca7b801effc39d7826a1255e8221c9' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='8f962f84bd36f5caad78710b32e074406d12e864e334bf6c8820836dbd1b6409' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='faa9de31cc41c0ecb79382569f1269758a7e51ca526aaf849d7189da6e28f716' ;; \
		*) goRelArch='src'; goRelSha256='fcf58935236802929f5726e96cd1d900853b377bec2c51b2e37219c658a4950f'; \
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
