FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.9rc2

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='0d17d440f02505d8fbf6becb777175c242486c1d71046705876dcd20e0574002' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='c61a2efe5127e88c20a49278b9748a326af197bb38949387710119914d1d77a4' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='c53bdbc41fcd980f4ad6e5f216913053709479871cd395990fa4bf4f01c21e7d' ;; \
		i386) goRelArch='linux-386'; goRelSha256='b4d9e1f2f0f4f406150f21f7d166fa6f6ca54d7370752dc77e5b9f2ca2850dd0' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='765f844aec22328d5f3347c42b22f240ad0ecb78cc6f5f55d35e47d0379cfc79' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='1ec407c52ed02c472a71412733940c065666ceb76b83192c0ca09c70502b409d' ;; \
		*) goRelArch='src'; goRelSha256='12b09ea6cb3189ea5e4c057f7047b5709ae8edd14706421b188f7e4ae8d8d3e4'; \
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
