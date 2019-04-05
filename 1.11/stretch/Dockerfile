FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11.7

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='db687814288b3b541c1754dfd4ecc2b8fd0d5e7995624945e3054a350ca573d8' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='7d6ae2e119a432a4b00a6dc2c2085f56ead4973f40d58e534308f1535b45afc2' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='fe7ba5046aa4f52ae8fa36531aac4a949ad8e10c02b0f4aa05a420b4e803f8c6' ;; \
		i386) goRelArch='linux-386'; goRelSha256='86d11a58bd99298719cb7ebea160255aefc56735d14089d2b2241d581967a482' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='43b04f58b37808f86f526e6f1a8d6643fe196c1314acc3d7db710ec9ae960d18' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='178932743c7af70c94f170f800202f490e0f85e74796dabe0a23d50630ba0333' ;; \
		*) goRelArch='src'; goRelSha256='cfbe1078fbb1e34e77ad09de40d96d47ef280ba15791da9f02fc05486a4b16bd'; \
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
