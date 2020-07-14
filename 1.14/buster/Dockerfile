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

ENV GOLANG_VERSION 1.14.5

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='82a1b84f16858db03231eb201f90cce2a991078dda543879b87e738e2586854b' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='fc99d9cea2f2699d338f7e0ceb40d89c02019eec2b6500011a8743104274a46c' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='27a3b3ca4fd60c8680cd2235d5ca38cad41ee8c41bd61891d39a8501ada5f677' ;; \
		i386) goRelArch='linux-386'; goRelSha256='a2f8e961b2eb4b477f0e938e9e6f08d1aac6d677c6d934ac1e532d5c9314bf3e' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='581b858092e2a471c06e484f62206d3cde72f89e1cbde6284cfa09f824457b24' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='3ef0d07ecfcfe0a4bdf1cd68e769887a3a4d3279f5edc84ea08cc2c9a6ef1d1b' ;; \
		*) goRelArch='src'; goRelSha256='ca4c080c90735e56152ac52cd77ae57fe573d1debb1a58e03da9cc362440315c'; \
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
