FROM buildpack-deps:jessie-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.8.6

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='f558c91c2f6aac7222e0bd83e6dd595b8fac85aaa96e55d15229542eb4aaa1ff' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='590cd6a06bb7482b0fb98d8a4f3a149975a9bfa6a32f20e85a4c0c68f3dc120d' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='7ed8fd5b4109394e23a6a120686b8ee91806d6f9b16222ca9dbc8778e7a2fbc4' ;; \
		i386) goRelArch='linux-386'; goRelSha256='04e8a97ef3431e3157fe2629f9b162f8f845ea52bddf8b56bad2c9e21041b3b6' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='9a02793709d68085929c492f3f9cad140845185eaef8510f66c8a79fed2170e2' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='571c438b3b9df2b3b9987712a3ce8c0ace6c0d45c3ac3d9224d864e2aa8cbd89' ;; \
		*) goRelArch='src'; goRelSha256='efc1221d3ae033c69e149801eff1d9872e214832a89f089fc5beb7a9fd98d9fb'; \
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
