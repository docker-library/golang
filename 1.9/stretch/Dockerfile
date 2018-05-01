FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.9.6

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='d1eb07f99ac06906225ac2b296503f06cc257b472e7d7817b8f822fe3766ebfe' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='73e56ec4408650d9fda0be8282a9ad49c51ad17929b4d20c04cea07249726bd8' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='8596d64b9f582d6209c04513824e428d1c356276180d2089d4dfcf4c7cf8a6cc' ;; \
		i386) goRelArch='linux-386'; goRelSha256='de65e35d7e540578e78a3c6917b9e9033b55617ef894a1de1a6a6da5a1b948dd' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='b1203546c68e3be7b5e36a5cfb6ff5ef94bd476f5423035bc7e65255858741ff' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='2baa6e48eedb8ec7e2a4d2454cdf05d1f46d5a07ff2f03cab5b7b8eadef7e112' ;; \
		*) goRelArch='src'; goRelSha256='36f4059be658f7f07091e27fe04bb9e97a0c4836eb446e4c5bac3c90ff9e5828'; \
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
