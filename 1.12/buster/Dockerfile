FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.16

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='bf3a85d75658144c06ce986ba05e07ef08af4320089b74b1d41de3b0f340ea7e' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='2f77688eaf25d8ae58adc5164de0fc13d600705c2ebadc6e1138e5ce9ceadc41' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='a01df310bfeffc67480982cf6ad50c9b83f9aaf4ac855d5e581b95eb727bb24c' ;; \
		i386) goRelArch='linux-386'; goRelSha256='e6ebf5622203f2ceee138af16c765818bf65b74668d5e73c1da6491c3e890a88' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='7c133932d1beae68a483dbac69bb0e1023fa08196ebee100594b79c0672ce67c' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='e93326caefb3945054f9c98dd7934892b69dcb46d343cd3582c777874f5d2716' ;; \
		*) goRelArch='src'; goRelSha256='ce6e5ed85b4a54ffc01d55a5838ee313acb4a7f109a745440fecbead1d081df8'; \
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
