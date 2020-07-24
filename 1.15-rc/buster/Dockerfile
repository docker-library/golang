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

ENV GOLANG_VERSION 1.15rc1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='ac092ebb92f88366786063e68a9531d5eccac51371f9becb128f064721731b2e' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='d42df2b62fc7569931fb458952b518e1ee102294efcc4e28c54cce76a7f4cd8f' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='3baf4336d1bcf1c6707c6e2a402a31cbc87cbd9a63687c97c5149911fe0e5beb' ;; \
		i386) goRelArch='linux-386'; goRelSha256='e8b09a03cf057fe68806c0d2954ab8d9ca3002558d8ce60a196b836dacb91f4b' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='a8599883755d188d24a5012f72f99b3237c2f5223bc1f937b6f055456c1468e3' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='0a16994b1f988db12aa44aa9965ae4d07d067489c321e5f7445eb2be63fe2466' ;; \
		*) goRelArch='src'; goRelSha256='a19c4d5053a01c1b71827ab6d86f43f2a5266309aa622e04446756304f179c1a'; \
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
