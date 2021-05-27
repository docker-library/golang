FROM vaporio/buildpack-deps:bionic-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.15.12

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='bbdb935699e0b24d90e2451346da76121b2412d30930eabcd80907c230d098b7' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='6a20048f7061d06f590d869a5298e8c0ffc325e8faf0bb8b6a622ad007a53028' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='a10161e6f0389c45ecd810e114acaba967ea3a4def551fcbb0b1e270996103ed' ;; \
		i386) goRelArch='linux-386'; goRelSha256='d186ccaa0080e301d35fa49a244877da6f08a1aeda3ed90438fee835538f7ece' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='c94c105e4e985b5675aa434845cced73a64bb050a8a96fa0e9b17dbea3ac6684' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='9f1daa296e44ec0ce6b648e4e6d63210584b6c1ae2e46c77c8030b77514e8a8e' ;; \
		*) goRelArch='src'; goRelSha256='1c6911937df4a277fa74e7b7efc3d08594498c4c4adc0b6c4ae3566137528091'; \
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
