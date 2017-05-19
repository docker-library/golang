FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.8

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='7e78afe33377b4d4c04817d48feb9f2a904406d32216df015d44462f0432643b' ;; \
		i386) goRelArch='linux-386'; goRelSha256='8f618dc8b01c2e53e639a38d780645b8424e671e292c7b518248022205d6a448' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='fb893a546902c2afdff929ddf5a9fbc0fd50b9017126ee85e80604d8620010fe' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='32553dbb342f74a821ed5069cb72ec7e135c031102e7d01c6bc4da8ad6df5202' ;; \
		amd64) goRelArch='linux-amd64'; goRelSha256='53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca' ;; \
		*) goRelArch='src'; goRelSha256='406865f587b44be7092f206d73fc1de252600b79b3cacc587b74b5ef5c623596'; \
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

COPY go-wrapper /usr/local/bin/
