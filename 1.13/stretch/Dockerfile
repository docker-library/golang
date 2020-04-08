FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13.10

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='8a4cbc9f2b95d114c38f6cbe94a45372d48c604b707db2057c787398dfbf8e7f' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='3c581f11ed49eaf0954f62ffebc123f8c392fc536f01c5a44cb38185701101fc' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='f16f19947855b410e48f395ca488bd39223c7b35e8b69c7f15ec00201e20b572' ;; \
		i386) goRelArch='linux-386'; goRelSha256='233c9d43fe2fab27ee489efea08b84665aec5855cce95a81dba3846636de5fed' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='6b9505388ecafa3cb04d5f51638276b25f7d80c5f70bd74ed72f8013f5006fd9' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='41cb67266e809920363ff620e8cabce152ab54bebd6a337e9f903f5c1996ec35' ;; \
		*) goRelArch='src'; goRelSha256='eb9ccc8bf59ed068e7eff73e154e4f5ee7eec0a47a610fb864e3332a2fdc8b8c'; \
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
