FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13.7

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='b3dd4bd781a0271b33168e627f7f43886b4c5d1c794a4015abf34e99c6526ca3' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='ff8b870222d82c38a0108810706811dcbd1fcdbddc877789184a0f903cbdf11a' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='8717de6c662ada01b7bf318f5025c046b57f8c10cd39a88268bdc171cc7e4eab' ;; \
		i386) goRelArch='linux-386'; goRelSha256='93e82683f32d9fe7fda9b686415aeee599a92c4e450b69519bb53e1d62144a85' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='8fe0aeb41e87fd901845c9598f17f1aae90dca25d2d2744e9664c173fbf7f784' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='7d405e515029d19131bae2820310681c31b665178998335ecc4494e8de01dfeb' ;; \
		*) goRelArch='src'; goRelSha256='e4ad42cc5f5c19521fbbbde3680995f2546110b5c6aa2b48c3754ff7af9b41f4'; \
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
