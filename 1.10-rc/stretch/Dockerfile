FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.10beta2

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='ab3abb7d731dd5ac7a06d5d5e64ef19946f57d4ce34555d262a87b8899901a93' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='777a59c2b1516598e161c0c5b25809c83fdec3737a0b7f4942c855259d57b3fe' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='2f51e94a227473d41bf3d9dbbdc5855308e64d82fb740a15019bd4fe733c9518' ;; \
		i386) goRelArch='linux-386'; goRelSha256='4e5bc465a828c88e0e3c6049c58ee735d8ca27a994bc1d709424425cd20cab79' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='ace75d03dc73351320d055535f1f314b7dbd27ab21c7878db27a385b1e00d5b0' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='4d8625f071edd2cb2b16251f23530a43f9ff64db1b6ce080daff0dcc984005da' ;; \
		*) goRelArch='src'; goRelSha256='a77c130eabfdea21fca629276f509b18da925912509903102b49113bc7dede9d'; \
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
