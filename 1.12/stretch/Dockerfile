FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.3

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='3924819eed16e55114f02d25d03e77c916ec40b7fd15c8acb5838b63135b03df' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='efce59fac5ebc7302263ca1093fe2c3252c1b936f5b1ae08afc328eea0403c79' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='4deb7f3b90d03f71f5cac3654e0e1f9cb46c45b85c5475510222b958e4ea2ed6' ;; \
		i386) goRelArch='linux-386'; goRelSha256='67599ae0788ed88260531d4be4293cb8f5199e5c7e06d30c6bd95eb54f014be7' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='8bd04e742be8ed3f7f6fd2c78e2303be2ee70709cdc28758f101765a5e7d6dc1' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='102fe607818ba21b9853ddfa3b1225b2af802010af3a032c6487144fbb7f3521' ;; \
		*) goRelArch='src'; goRelSha256='5c507abe8818429d74ebb650a4155d36bc3f9a725e59e76f5d6aca9690be2373'; \
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
