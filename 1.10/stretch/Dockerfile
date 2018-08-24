FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.10.4

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='fa04efdb17a275a0c6e137f969a1c4eb878939e91e1da16060ce42f02c2ec5ec' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='4e1e80bd98f3598c0c48ba0c189c836d01b602bfc769b827a4bfed01d2c14b21' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='2e0f9e99aeefaabba280b2bf85db0336da122accde73603159b3d72d0b2bd512' ;; \
		i386) goRelArch='linux-386'; goRelSha256='771f48e55776d4abc9c2a74907457066c7c282ac05fa01cf5ff4422ced76d2ee' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='1cfc147357c0be91a988998046997c5f30b20c6baaeb6cd5774717714db76093' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='5593d770d6544090c1bb20d57bb34c743131470695e195fbe5352bf056927a35' ;; \
		*) goRelArch='src'; goRelSha256='6fe44965ed453cd968a81988523e9b0e794d3a478f91fd7983c28763d52d5781'; \
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
