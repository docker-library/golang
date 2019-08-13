FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11.13

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='50fe8e13592f8cf22304b9c4adfc11849a2c3d281b1d7e09c924ae24874c6daa' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='513eb46158917662e1588cb89f51d11839730e46847778646c36c69c687bfdc5' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='e94329c97b38b5bffe9c18e84e9f521dc995e02df7696897a7626293da9ac593' ;; \
		i386) goRelArch='linux-386'; goRelSha256='282e20167a7aaaba7b23de980696e1944a004efd0079e80d675d66b263ef595b' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='ad3c7397ddd41a5af9d9bf3c560d3d0f8c1bdef4ac4d21819a021ea88e25efca' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='bd00bd27e641450f165a37a83f1e83a4ef3c626ef5675b77184e9c0147257657' ;; \
		*) goRelArch='src'; goRelSha256='5032095fd3f641cafcce164f551e5ae873785ce7b07ca7c143aecd18f7ba4076'; \
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
