FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.14

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='08df79b46b0adf498ea9f320a0f23d6ec59e9003660b4c9c1ce8e5e2c6f823ca' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='b5e682176d7ad3944404619a39b585453a740a2f82683e789f4279ec285b7ecd' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='cd813387f770c07819912f8ff4b9796a4e317dee92548b7226a19e60ac79eb27' ;; \
		i386) goRelArch='linux-386'; goRelSha256='cdcdab6c8d1f2dcea3bbec793352ef84db167a2eb6c60ff69e5cf94dca575f9a' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='b896b5eba616d27fd3bb8218de6bef557cb62221e42f73c84ae4b89cdb602dec' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='22e67470fe872c893face196f02323a11ffe89999260c136b9c50f06619e0243' ;; \
		*) goRelArch='src'; goRelSha256='6d643e46ad565058c7a39dac01144172ef9bd476521f42148be59249e4b74389'; \
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
