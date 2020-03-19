FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13.9

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='f4ad8180dd0aaf7d7cda7e2b0a2bf27e84131320896d376549a7d849ecf237d7' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='a3c2941a1fde8692514ece7e2180a0e3ca70609f52756a66bc0ab68c63572361' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='b53cb466d7986e5e17a3d4c196bc95df08a35968eced5efd7e128387a246c46e' ;; \
		i386) goRelArch='linux-386'; goRelSha256='a2744aa2ddc68d888e9f65c2cbe4c8b527b139688ce232ead90dc2961f8d51a8' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='90beb01962202f332be0a7c8dad2db3d30242759ba863db3f36c45d241940efc' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='a40949aaf55912b06df8fda511c33fde3e52d377706bdc095332652c1ad225e3' ;; \
		*) goRelArch='src'; goRelSha256='34bb19d806e0bc4ad8f508ae24bade5e9fedfa53d09be63b488a9314d2d4f31d'; \
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
