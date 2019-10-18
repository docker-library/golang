FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13.2

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='293b41a6ccd735eebcfb4094b6931bfd187595555cecf3e4386e9e119220c0b7' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='6f2e90b5d08a177be14938a905f7b91e9b17052318b5ea0e6d7c0a83af252421' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='a2d27f341d6b7968f9da229990aa9ab7a6d4bd1c722945be11576a09eb538482' ;; \
		i386) goRelArch='linux-386'; goRelSha256='468f116889631405da0c89b1765985e8bbeddbf8642c2a552a81f0bfbe58ab55' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='ffcc3651fce34fc6418e33836d5417c0e6b713fda99033259e67538fa802900a' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='dbed59db3e4f57df7c86120be37bdbf3516891214174b771cff40d81ba8577e2' ;; \
		*) goRelArch='src'; goRelSha256='1ea68e01472e4276526902b8817abd65cf84ed921977266f0c11968d5e915f44'; \
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
