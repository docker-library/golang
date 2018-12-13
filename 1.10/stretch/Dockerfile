FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.10.6

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='acbdedf28b55b38d2db6f06209a25a869a36d31bdcf09fd2ec3d40e1279e0592' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='4da252fc7e834b7ce35d349fb581aa84a08adece926a0b9a8e4216451ffcb11e' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='0fcbfbcbf6373c0b6876786900a4a100c1ed9af86bd3258f23ab498cca4c02a1' ;; \
		i386) goRelArch='linux-386'; goRelSha256='171fe6cbecb2845b875a35ac7ad758d4c0c5bd03f330fa35d340de85b9070e71' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='ebd7e4688f3e1baabbc735453b19c6c27116e1f292bf46622123bfc4c160c747' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='0223daa57bdef5bf85d308f6d2793c58055d294c13cbaca240ead2f568de2e9f' ;; \
		*) goRelArch='src'; goRelSha256='0f6bd961f6d2d6fa6319b7dc9548e2ae22d0698e7432d4cabf737542913f8c14'; \
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
