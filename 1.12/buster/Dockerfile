FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.12

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='4cf11ac6a8fa42d26ab85e27a5d916ee171900a87745d9f7d4a29a21587d78fc' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='ed3cda3c2d0648a712fa13cfc25e82431772231ef8f3db70de2fa9c2b893a5ab' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='a7e2fed536904f2bf7007deed3609b3484c55660821bd2faaeb6928fa62fd33e' ;; \
		i386) goRelArch='linux-386'; goRelSha256='59a48035f9b1387347e8a8a0f7c6d693e6bc84e0374ef802fb8ec61f894db073' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='adee3f914baf578bd21526479f45f99782791dcd12bfba2a7ca2d3fb79e4d623' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='24b0be352713a6e047b21093cf2aaaf22c7757d3606839ddd26da60e7f18dba6' ;; \
		*) goRelArch='src'; goRelSha256='fcb33b5290fa9bcc52be3211501540df7483d7276b031fc77528672a3c705b99'; \
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
