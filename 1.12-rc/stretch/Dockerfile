FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12rc1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='e5a03e1f2e065b17b2fbbd3429f18a6f51fe2848e0120586652b9f14ada72c9a' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='62126e4ca72e2fea9856fe0ec1a0f28cf1b385fb362d32cb56413c39cab318f8' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='654b90f75902d501e2201a7b438965132fd1242a102f54529e9ff7dbbdf0d4bb' ;; \
		i386) goRelArch='linux-386'; goRelSha256='1d8615576655decbadeefcfaa6d5144b370dbea67fd4b426f58b573deedbd918' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='cb6c7ba83ee8211da1d13d6db148adfdd6b86a790d3974d0c5702d229ca1da40' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='40208d21fca8469c20054e67250f288ab62d68794690aa2c0324d67018ba99c2' ;; \
		*) goRelArch='src'; goRelSha256='ed1d4f8e8a33f0d4a59a2f642584c7c6375fce2f8a4edaece73309cf2c89b8ee'; \
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
