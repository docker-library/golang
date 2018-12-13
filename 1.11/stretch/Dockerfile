FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.11.3

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='d20a4869ffb13cee0f7ee777bf18c7b9b67ef0375f93fac1298519e0c227a07f' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='384933e6e97b74c5125011c8f0539362bbed5a015978a34e441d7333d8e519b9' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='723c54cb081dd629a44d620197e4a789dccdfe6dee7f8b4ad7a6659f76952056' ;; \
		i386) goRelArch='linux-386'; goRelSha256='c3fadf7f8652c060e18b7907fb8e15b853955b25aa661dbd991f6d6bc581d7a9' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='57c89a047ef4f539580af4cadebf1364a906891b065afa0664592e72a034b0ee' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='183258709c051ceb2900dee5ee681abb0bc440624c8f657374bde2a5658bef27' ;; \
		*) goRelArch='src'; goRelSha256='7ec5140f384db2bd42b396c93c231dfba342ee137ad8a4b33120016951eb1231'; \
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
