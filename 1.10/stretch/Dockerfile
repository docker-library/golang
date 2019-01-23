FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.10.8

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='d8626fb6f9a3ab397d88c483b576be41fa81eefcec2fd18562c87626dbb3c39e' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='6fdbc67524fc4c15fc87014869dddce9ecda7958b78f3cb1bbc5b0a9b61bfb95' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='0921a76e78022ec2ae217e85b04940e2e9912b4c3218d96a827deedb9abe1c7b' ;; \
		i386) goRelArch='linux-386'; goRelSha256='10202da0b7f2a0f2c2ec4dd65375584dd829ce88ccc58e5fe1fa1352e69fecaf' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='9054bcc7582ebb8a69ca43447a38e4b9ea11d08f05511cc7f13720e3a12ff299' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='6f71b189c6cf30f7736af21265e992990cb0374138b7a70b0880cf8579399a69' ;; \
		*) goRelArch='src'; goRelSha256='6faf74046b5e24c2c0b46e78571cca4d65e1b89819da1089e53ea57539c63491'; \
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
