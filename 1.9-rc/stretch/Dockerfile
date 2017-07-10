FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.9beta2

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='023f778f063d2234e7c95f572a92298b307807693f7e045a88c90ecd7a08f29d' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='4be3d357c7a6ccd51c2fb89efbe32da3fa1d209f105f146429a7ea2c015e64dc' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='4e60b704f04441ad97b5a7c660a680225abd59b33b9044731066f2f91c18ddba' ;; \
		i386) goRelArch='linux-386'; goRelSha256='b06f1ef695560d687c94ebd83a0c2f6d1adfa37121ddd14d361816eaa2f00d44' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='52aad09c7b858a02d3de72ea971b656da698ef8be2647277d751b2210d9d1419' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='c8166dfb2af4290acffb9382ca3a5723e8b400c718cb634614c3248740c2067f' ;; \
		*) goRelArch='src'; goRelSha256='4ca11b29e9c3b2ef1db837a80bc3a54a6ba392dc3f7447cb99972f9c96daa8c3'; \
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
