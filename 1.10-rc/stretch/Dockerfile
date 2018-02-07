FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.10rc2

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='6a6a4c0654bc603bcfee4d6ac34a479c260ac61b3edcc8d6773384eb0bda512e' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='aa145c2a9736cbcb39b9340182c319f7fc0ab3d0f2156d7dfd722572f4da519b' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='dfa7fbe299b3766b94fb4bc231db4330b9860c44a57274f6a0d418bf00eccbc8' ;; \
		i386) goRelArch='linux-386'; goRelSha256='18832b97cdc2f21783ac60fc0136f25c19d39b7cc43459f5114dd62c0a212fe4' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='21a6e64c83df9f124993901dda2ec608640e97a13f50cf5a58f518651b576fd8' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='7d3aa6ec3a761b328e093b51ca14dbb8a8000685bb8957dbab44b4bb3b1d76e7' ;; \
		*) goRelArch='src'; goRelSha256='360bb3e627cd5308626ebe994be734da9c1c444fb420d10e79082ec110d004f6'; \
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
