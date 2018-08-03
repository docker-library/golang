FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11beta3

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='674c1091f4712c1cfdcd77ecddafe6aef81cbda740af64a6e3f893ddf3dfb11c' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='491e4d1288ad9f69d16e8ec990d4a4a2b9cc494c3b9488743a96c168424cbb5c' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='d8fb9d36a3c862a68db828eb22268e0723e3e245f41cc33f5da0a5b7e293fea5' ;; \
		i386) goRelArch='linux-386'; goRelSha256='e3e4e1271aa74f7dc64c586048f351e89d7ab20b5f3c3a518e87a628f5abf582' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='6fe3a4db6a43a59fbe364069fd94536e1d2920df897d5ec93bea7fd519031c54' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='518762a66c9992d667bf7cae4adda285d14f856413ccc7cd853876aae0670382' ;; \
		*) goRelArch='src'; goRelSha256='b11a92814601c85910e3f98dd06b941974d03b48c2c255defbee1cc99f19d721'; \
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
