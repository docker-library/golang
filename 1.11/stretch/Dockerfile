FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11.4

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='fb26c30e6a04ad937bbc657a1b5bba92f80096af1e8ee6da6430c045a8db3a5b' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='9f7a71d27fef69f654a93e265560c8d9db1a2ca3f1dcdbe5288c46facfde5821' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='b76df430ba8caff197b8558921deef782cdb20b62fa36fa93f81a8c08ab7c8e7' ;; \
		i386) goRelArch='linux-386'; goRelSha256='cecd2da1849043237d5f0756a93d601db6798fa3bb27a14563d201088aa415f3' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='1f10146826acd56716b00b9188079af53823ddd79ceb6362e78e2f3aafb370ab' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='4467442dacf89eb94c5d6f9f700204cb360be82db60e6296cc2ef8d0e890cd42' ;; \
		*) goRelArch='src'; goRelSha256='4cfd42720a6b1e79a8024895fa6607b69972e8e32446df76d6ce79801bbadb15'; \
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
