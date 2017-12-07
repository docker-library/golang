FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.10beta1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='ec7a10b5bf147a8e06cf64e27384ff3c6d065c74ebd8fdd31f572714f74a1055' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='32daa257a930ef85ca74bca107d477b3484f0b5ef7cc48086110916368d9c584' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='3a80555b3c4beecfb9af88c718f8676101ada74dea84f4aa1ade29d2d78554e0' ;; \
		i386) goRelArch='linux-386'; goRelSha256='e0f30e18384e3beae8ce16cc6d095d899e29fb786c57297650acb7727fb3090e' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='b4c7404771b380212277fecc3b9a4f99f9978d024a45d3644c495a469df31ed8' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='bc3c66ab980e782ce52165a3a1572484353904c1b884dbbb87a662776280489d' ;; \
		*) goRelArch='src'; goRelSha256='841df62b20fd915d83a2e43b7d043c2a3781c299de78abc45480eec575186b6b'; \
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
