FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11beta2

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='ccb60f1ae6efe4fcef115db8143eb7f9ba134c63486f47b2c5176706ede35af5' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='3242225cc9bb151789b4ba606903862b68b0e81682a5ab75245d76ab1ddf38fb' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='835fc6ebae5cb4368fc39683a911fe5a25c36b4251b2b254112f3fc8f36a9f39' ;; \
		i386) goRelArch='linux-386'; goRelSha256='acc26b494699f7dca7e30ec2c08d0f2af8813437a234f17605fafe9c7c8cf69e' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='31168f17e2791e664e591dc4c5e2c37ab5c3b942a2898d84075437daed3fc9f9' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='648b0f22ff517668bf4b642749a2a479d421f69b1e11bcd0ab1a71994e1c94db' ;; \
		*) goRelArch='src'; goRelSha256='50f4bd23334f54c60ad7d07c742874c62488cf1556fa3e6e51dc03d5f5abda81'; \
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
