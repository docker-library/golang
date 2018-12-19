FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12beta1

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='65bfd4a99925f1f85d712f4c1109977aa24ee4c6e198162bf8e819fdde19e875' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='e0ba7091227b42e98a9ed83f52e3821f7b3b836a16a5815ccf237bcaa590083a' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='df79a288b2c569bd26e43ea3acc245b7eabae897b4783f7b4acffdd97ba0a01c' ;; \
		i386) goRelArch='linux-386'; goRelSha256='5c93266b9b9f6e4ac452517b073a54d2dbb4cbbae901bc7e2b5d34415adf658b' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='8ae18d580913cc4cb67cdac36c058aad279419640f469931e44d6b7f0bbd9062' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='c575e5835a0ed3b19040497e24f7de6913eb73a42983e828f5dc2af4c9fcecf7' ;; \
		*) goRelArch='src'; goRelSha256='639585de6bfb67865a85cd750d41ecc39968039dafb9d1fdb15361eb118d150a'; \
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
