FROM buildpack-deps:buster-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13rc1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='0b45d086aefcfb9d0ebe7fc9ffbe470e45f9c104a6a97ea275512152cdbfead1' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='d0118038c68276179523dfffba3ad49662842b8e4e37b5801d753c731241d745' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='be16145c9fa218340766b19edd175b109adab826155add2fd504430a751aaa19' ;; \
		i386) goRelArch='linux-386'; goRelSha256='98368195013a6140573835db93038a7977c61cabff53618a785659edb9378bb1' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='e351c396262b3c411459e08a2ff9bec9d720760bd8811fd1f59262d02f9f504f' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='2fd64292498fb70074ff4560da4a7e444d3325c219a6987f4b2186d231244921' ;; \
		*) goRelArch='src'; goRelSha256='dc5c1f4501daf486f69ca9a795202b289824c303291bf26c42a5b6c1770ba3a9'; \
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
