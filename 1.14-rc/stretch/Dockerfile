FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.14rc1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='69398d41e5f6b87cdf3969aae665be4dfd3cc2ef36a61ab47a261f96130ed788' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='bfe041f7d2a62f895f2d11703a29bdd31a48cca9a3c36418d59680bc1cbb8a6d' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='a5509448b06f02f5198fe8bbf5af88ab483af9c46f231c3f308748016fbc32c9' ;; \
		i386) goRelArch='linux-386'; goRelSha256='831087aa0eba8b6dfa221036d00641613996ac66d7c635f1e34c53d5f0922623' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='fe1bf34d2b117d785f2fb33151c44ca8bc2188678c9e903fa0ad30573547b412' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='2302fa0e30144a969cb1879eed8aeb9a82c2b520fcda8aebbb20a539ad427c25' ;; \
		*) goRelArch='src'; goRelSha256='76188ea84e95baa502d058c9598020c7654d6adaf40b82cabcf57c68df19963a'; \
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
