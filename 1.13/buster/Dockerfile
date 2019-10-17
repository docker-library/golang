FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13.3

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='0804bf02020dceaa8a7d7275ee79f7a142f1996bfd0c39216ccb405f93f994c0' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='9f15d6aa4098cd53ec5cb48d1a1e554d062b2263a03985d50c2568757d966dc6' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='9fa65ae42665baff53802091b49b83af6f2e397986b6cbea2ae30e2c7ee0f2f2' ;; \
		i386) goRelArch='linux-386'; goRelSha256='c68ebb127924ee753d05fcd4cc893e3409a6754e8884bb04e5248e9b5849f6ba' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='2373b60d7f7b4825b1d0ec195079833a3dac72ddd55b207ee22b0032b1a658d9' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='9241ce5bf362b7066c90da5abc4c85ec7b4054637e1a8a01b8cc83281e228b7e' ;; \
		*) goRelArch='src'; goRelSha256='4f7123044375d5c404280737fbd2d0b17064b66182a65919ffe20ffe8620e3df'; \
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
