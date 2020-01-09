FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13.6

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='a1bc06deb070155c4f67c579f896a45eeda5a8fa54f35ba233304074c4abbbbd' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='37a1a83e363dcf146a67fa839d170fd1afb13009585fdd493d0a3370fbe6f785' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='0a18125c4ed80f9c3045cf92384670907c4796b43ed63c4307210fe93e5bbca5' ;; \
		i386) goRelArch='linux-386'; goRelSha256='27feb013106da784f09e560720aa41ab395c67f7eed4c4a0fce04bc6e3d01c7d' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='26a977a8af5dc50a562f0a57b58dded5fa3bacfe77722cf8a84ea54ca54728dd' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='5cd9900a1fa0f0cac657930b648381cad9b8c5e2bbc77caf86a6fb5cedad0017' ;; \
		*) goRelArch='src'; goRelSha256='aae5be954bdc40bcf8006eb77e8d8a5dde412722bc8effcdaf9772620d06420c'; \
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
