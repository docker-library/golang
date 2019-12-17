FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.14beta1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='ebe68aa4219b673dbd060b8a6d9a339b6b6b0383772aa4349c8183f0a8f339e4' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='f0542513b997ef6b5f6ff4b9a2b9502fe6743746f2639ffd48dd53d7cb958f6d' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='91a92cfb7644c59c4b51d50fb7225b898675effaa65659a71c06aa6a42c0ada5' ;; \
		i386) goRelArch='linux-386'; goRelSha256='bcbfb2ea92cfef54c587427435ae5cbe50473d9158beef97aa5d5edd43d1a9d8' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='69f8d16e13912cd3caa2fe70addae9929d518d6c875cfd581bd914e0ce2d6d80' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='3252c14611af17e435a5160467c581acc31b4a4ce4e8e17688befabba3ba710f' ;; \
		*) goRelArch='src'; goRelSha256='af952217fcb408180006f29e77f1c3b871192fba7f99abd5aa421cf2f0358fea'; \
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
