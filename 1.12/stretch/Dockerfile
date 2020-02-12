FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.17

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='a53dd476129d496047487bfd53d021dd17e0c96895865a0e7d0469ce3db8c8d2' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='a883c806fccb3eddb26da4a1a1f8536de863aee6807ed6c99606261877af7b99' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='9d0819cce1451abdb090071880fe8771f16a3bcee71d6f6906023d17799574e2' ;; \
		i386) goRelArch='linux-386'; goRelSha256='e33fc10c0486b02a019f120996d77792d8f19aae8bfdda97350a622a65d6b824' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='dca4df132da7579c352bccd9d6f4ecb8d8d61893a84b0feffcee2bb4246114a3' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='e50ffb6e0d7e7573ed9ca0f5228bdd43238a25ac34916de027036ff97322d236' ;; \
		*) goRelArch='src'; goRelSha256='de878218c43aa3c3bad54c1c52d95e3b0e5d336e1285c647383e775541a28b25'; \
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
