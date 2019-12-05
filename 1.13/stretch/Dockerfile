FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13.5

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='512103d7ad296467814a6e3f635631bd35574cab3369a97a323c9a585ccaa569' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='26259f61d52ee2297b1e8feef3a0fc82144b666a2b95512402c31cc49713c133' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='227b718923e20c846460bbecddde9cb86bad73acc5fb6f8e1a96b81b5c84668b' ;; \
		i386) goRelArch='linux-386'; goRelSha256='3b830fa25f79ab08b476f02c84ea4125f41296b074017b492ac1ff748cf1c7c9' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='292814a5ea42a6fc43e1d1ea61c01334e53959e7ab34de86eb5f6efa9742afb6' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='cfbb2959f243880abd1e2efd85d798b8d7ae4a502ab87c4b722c1bd3541e5dc3' ;; \
		*) goRelArch='src'; goRelSha256='27d356e2a0b30d9983b60a788cf225da5f914066b37a6b4f69d457ba55a626ff'; \
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
