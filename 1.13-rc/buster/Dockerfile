FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13rc2

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='3cd4490021a5f1f25a7440edca03910e40a38e587b578cf52ab7143a81db1861' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='deebe2b723c818293046629344f09ead1610fba608aea038bcf25da70766f944' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='184c9fff6bba9da1cf23ba7f52561cc777ac7feaf73621b3824f4a30ffa4648d' ;; \
		i386) goRelArch='linux-386'; goRelSha256='5f5d235b73672ee5d26917d3907f8f1966af60d4391477a5afd4300d070ca852' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='7656da8bb13e450754d5df35c7d21dafb5847b00779dcc08f3c41eec7d817037' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='6016103bab62f1fe6b8f90665888a23ae8c825a8e7db7a607877298148e593cf' ;; \
		*) goRelArch='src'; goRelSha256='0c7387b3be32718282a39faa3020ff30365ef70e64fa71e10017a986587b7fe9'; \
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
