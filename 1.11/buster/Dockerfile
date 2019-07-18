FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11.12

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='14ec881815eb9e6618f95df5eb385d961283efc196d97912595ba6484a56180d' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='5ffe422dc054909da4e468cb0df6e2cd41cebfe4fd9515f32bb3e3fbfc416016' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='d79c075773fc3121d0e719b83b46115efff685ade94545a52f3ac22f43d76196' ;; \
		i386) goRelArch='linux-386'; goRelSha256='8467e68d6ed6f6a95c6db6a1e352fc529f256bba0955eaef472e50cf4c0cba61' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='92bd4dc0dc8227fb22ad88545dd72669923019760cd640d4cca189860870561a' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='a4d100a1c92e50fd9b8a4d529da0ef0f4509c72643d6fb481918fd543f5871c0' ;; \
		*) goRelArch='src'; goRelSha256='6d7a5ba05476609a7614af3292f29c3be06327503c1f1fdc02ef417870fd6926'; \
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
