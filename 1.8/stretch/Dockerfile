FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.8.5

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='4f8aeea2033a2d731f2f75c4d0a4995b357b22af56ed69b3015f4291fca4d42d' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='f5c58e7fd6cdfcc40b94c6655cf159b25836dffe13431f683b51705b8a67d608' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='6c552ae1e77c52944e0f9b9034761bd3dcc3fef57dad6d751a53638783b07d2c' ;; \
		i386) goRelArch='linux-386'; goRelSha256='cf959b60b89acb588843ff985ecb47a7f6c37da6e4987739ab4aafad7211464f' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='1ee0874ce8c8625e14b4457a4861777be78f30067d914bcb264f7e0331d087de' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='e978a56842297dc8924555540314ff09128e9a62da9881c3a26771ddd5d7ebc2' ;; \
		*) goRelArch='src'; goRelSha256='4949fd1a5a4954eb54dd208f2f412e720e23f32c91203116bed0387cf5d0ff2d'; \
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
