FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.9rc1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='a8ea2ac09878b7a5ac04fe52f144cdc64ab637230638af6975c0f1facbba3ec2' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='634940f127ab3f60ed4acf0985ff4b3d15a9d7a9eb9547e8a112b282fc182ff9' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='e1d6f224b3abf6d98530f69f7a2802dfbecf696d1c8b25e3885e1f78e7e0d42b' ;; \
		i386) goRelArch='linux-386'; goRelSha256='c8bc26be65faf73289aca64c5096302962bb2b76bcadf19dfa14d0b99a8d42e0' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='34c7cb9e34509fd76ef16fb58ccd88f44d14c5c8720cd2f9dcacd560d0d4caa8' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='8e8a5d7b25721a5c81f4117569ffb9fce280a0dea6fff012b31403fed0e6bb2b' ;; \
		*) goRelArch='src'; goRelSha256='87717598ea60cc6143afa48f141f7e1308e196b71862028e710b910f376b452e'; \
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
