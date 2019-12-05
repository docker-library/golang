FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.14

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='925a1a9d8b31c2425d7313fe73d3342288968a66e26cd8bf1b6b5656f4603fcb' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='c7aa5562168b6eb3a4bb54af061d68bcb6b9ecae9d785f9a38255c107c986b73' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='1ab765f4cf74f05cfba40ddcea9160ca6cf9a57915036a559ca1691942862e7c' ;; \
		i386) goRelArch='linux-386'; goRelSha256='76dda90b4fc0410212094b433cfdc40c9802fba972427e95cbdec3c5b94fd7a6' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='4e237b1357922e186337989914201e98bd9aed855f4034a5918476650484f83d' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='affd9764e5b163591ca87f351984c17d74e518e03b9d5e16f2be57bd30a82c80' ;; \
		*) goRelArch='src'; goRelSha256='39dbf05f7e2ffcb19b08f07d53dcc96feadeb1987fef9e279e7ff0c598213064'; \
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
