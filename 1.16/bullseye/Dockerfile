#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:bullseye-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.16.7

RUN set -eux; \
	\
	dpkgArch="$(dpkg --print-architecture)"; \
	url=; \
	case "${dpkgArch##*-}" in \
		'amd64') \
			url='https://dl.google.com/go/go1.16.7.linux-amd64.tar.gz'; \
			sha256='7fe7a73f55ba3e2285da36f8b085e5c0159e9564ef5f63ee0ed6b818ade8ef04'; \
			;; \
		'armel') \
			export GOARCH='arm' GOARM='5' GOOS='linux'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.16.7.linux-armv6l.tar.gz'; \
			sha256='b2973ceeae234866368baf9469fb7b9444857e50dc785ba879d98a0aa208a12b'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go1.16.7.linux-arm64.tar.gz'; \
			sha256='63d6b53ecbd2b05c1f0e9903c92042663f2f68afdbb67f4d0d12700156869bac'; \
			;; \
		'i386') \
			url='https://dl.google.com/go/go1.16.7.linux-386.tar.gz'; \
			sha256='5c0c8891fa88993f2193fbc9dd5cca6c250c89aa8c12bbaa382b6ff38139bcc3'; \
			;; \
		'mips64el') \
			export GOARCH='mips64le' GOOS='linux'; \
			;; \
		'ppc64el') \
			url='https://dl.google.com/go/go1.16.7.linux-ppc64le.tar.gz'; \
			sha256='03e02b2ac6dc1601203f335385b9bbe15a55677066d9a1a1280b5fcfa6ec4738'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.16.7.linux-s390x.tar.gz'; \
			sha256='5f691c9551710ebb17bbda04389944aa7332f42ab28f92516a69fbd7860e7e9f'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$dpkgArch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	build=; \
	if [ -z "$url" ]; then \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
		build=1; \
		url='https://dl.google.com/go/go1.16.7.src.tar.gz'; \
		sha256='1a9f2894d3d878729f7045072f30becebe243524cf2fce4e0a7b248b1e0654ac'; \
		echo >&2; \
		echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; \
		echo >&2; \
	fi; \
	\
	wget -O go.tgz.asc "$url.asc" --progress=dot:giga; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum --strict --check -; \
	\
# https://github.com/golang/go/issues/14739#issuecomment-324767697
	export GNUPGHOME="$(mktemp -d)"; \
# https://www.google.com/linuxrepositories/
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC EC91 7721 F63B D38B 4796'; \
	gpg --batch --verify go.tgz.asc go.tgz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" go.tgz.asc; \
	\
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ -n "$build" ]; then \
		savedAptMark="$(apt-mark showmanual)"; \
		apt-get update; \
		apt-get install -y --no-install-recommends golang-go; \
		\
		( \
			cd /usr/local/go/src; \
# set GOROOT_BOOTSTRAP + GOHOST* such that we can build Go successfully
			export GOROOT_BOOTSTRAP="$(go env GOROOT)" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
			./make.bash; \
		); \
		\
		apt-mark auto '.*' > /dev/null; \
		apt-mark manual $savedAptMark > /dev/null; \
		apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
		rm -rf /var/lib/apt/lists/*; \
		\
# pre-compile the standard library, just like the official binary release tarballs do
		go install std; \
# go install: -race is only supported on linux/amd64, linux/ppc64le, linux/arm64, freebsd/amd64, netbsd/amd64, darwin/amd64 and windows/amd64
#		go install -race std; \
		\
# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain
		rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
		; \
	fi; \
	\
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
