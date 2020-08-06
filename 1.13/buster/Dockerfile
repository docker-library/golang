FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.13.15

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='01cc3ddf6273900eba3e2bf311238828b7168b822bb57a9ccab4d7aa2acd6028' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='c58eacae1745769e77328aec08e0e3b4da1b4e99e1153046b1b00ae0b3338d42' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='a5c59e3f0aeaf6e939790152a8bfabb91d70c9787afb7aee06aef9bd4411c551' ;; \
		i386) goRelArch='linux-386'; goRelSha256='1a63e97b6f1a673966d6a4f4f7f9c724fdd68bdeac11425bf8a39c7a24ddc0a7' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='bee55510a87bd366381df0be4736fd5cc89523228f9ca20eb1687f59e80ca029' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='6c370800d470ae116a9521f5439b3fa6271f06a6d4c2a18913c8c6226d78fe4b' ;; \
		*) goRelArch='src'; goRelSha256='5fb43171046cf8784325e67913d55f88a683435071eef8e9da1aa8a1588fcf5d'; \
			echo >&2; echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; echo >&2 ;; \
	esac; \
	\
	url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz"; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "${goRelSha256} *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
# https://github.com/golang/go/issues/38536#issuecomment-616897960
	if [ "$goRelArch" = 'src' ]; then \
		savedAptMark="$(apt-mark showmanual)"; \
		apt-get update; \
		apt-get install -y --no-install-recommends golang-go; \
		\
		goEnv="$(go env | sed -rn -e '/^GO(OS|ARCH|ARM|386)=/s//export \0/p')"; \
		eval "$goEnv"; \
		[ -n "$GOOS" ]; \
		[ -n "$GOARCH" ]; \
		( \
			cd /usr/local/go/src; \
			./make.bash; \
		); \
		\
		apt-mark auto '.*' > /dev/null; \
		apt-mark manual $savedAptMark > /dev/null; \
		apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
		rm -rf /var/lib/apt/lists/*; \
		\
# pre-compile the standard library, just like the official binary release tarballs do
		go install std; \
# go install: -race is only supported on linux/amd64, linux/ppc64le, linux/arm64, freebsd/amd64, netbsd/amd64, darwin/amd64 and windows/amd64
#		go install -race std; \
		\
# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain
		rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
		; \
	fi; \
	\
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
