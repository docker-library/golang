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

ENV GOLANG_VERSION 1.13.12

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='9cacc6653563771b458c13056265aa0c21b8a23ca9408278484e4efde4160618' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='552db731a120d341a1756c6ce0b1029cb5f5c756c09de9f45273893268d19c23' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='7a8b4e7841d978c95dae8ef53e19811ee2d5c595a1c5ec7afed74bb8f71588b8' ;; \
		i386) goRelArch='linux-386'; goRelSha256='625d9cdb25ba55e1afba9490c79c55767117fa272e067f81643d22268d51308a' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='97d762a62eae2e1f4d89ce09a89407a63e12c22d5c0fb952e409b323927cd38e' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='8dd2d50666176cbe5cab7557081acb0f380cef2240e18d05db7faffc03d8f356' ;; \
		*) goRelArch='src'; goRelSha256='17ba2c4de4d78793a21cc659d9907f4356cd9c8de8b7d0899cdedcef712eba34'; \
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
