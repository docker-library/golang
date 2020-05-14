FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13.11

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='a4d71ca9e02923fa96669a4b5faf78ee8331b18e7209b09dd87fe763b4838ada' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='f762f3acdaf2bb8d32041110022104aa430d96c39a8fc9cf3d4ab74faa607fca' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='6c81c0ce79be2bd3ac5ea69c709ea9bd588069632ded4ac39d58dadf4d2f93e6' ;; \
		i386) goRelArch='linux-386'; goRelSha256='c61ea511a4e82e9a7d31684d33c7b8bbb275e4110490f9a320c8026b76cac4ee' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='d9697e5bcf3a3ac0ba1ff299bb72ffd4957b9893a19a1e65adce683144d795e3' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='076f31fb29aa5129151aaf850593b16b4391157870a15a3f0199554a99db0b9b' ;; \
		*) goRelArch='src'; goRelSha256='89ed1abce25ad003521c125d6583c93c1280de200ad221f961085200a6c00679'; \
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
