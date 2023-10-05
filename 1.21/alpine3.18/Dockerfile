#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18

RUN apk add --no-cache ca-certificates

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.21.2

RUN set -eux; \
	apk add --no-cache --virtual .fetch-deps gnupg; \
	arch="$(apk --print-arch)"; \
	url=; \
	case "$arch" in \
		'x86_64') \
			url='https://dl.google.com/go/go1.21.2.linux-amd64.tar.gz'; \
			sha256='f5414a770e5e11c6e9674d4cd4dd1f4f630e176d1828d3427ea8ca4211eee90d'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.21.2.linux-armv6l.tar.gz'; \
			sha256='8727d842176a2bfd9edf307ed5411c39a69e2c6a748098987be361e8e0c36b46'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.21.2.linux-armv6l.tar.gz'; \
			sha256='8727d842176a2bfd9edf307ed5411c39a69e2c6a748098987be361e8e0c36b46'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.21.2.linux-arm64.tar.gz'; \
			sha256='23e208ca44a3cb46cd4308e48a27c714ddde9c8c34f2e4211dbca95b6d456554'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.21.2.linux-386.tar.gz'; \
			sha256='e2ccb4121a328c3fa297c6d653cc0a625a06935313c2367f8e026c3af56869c5'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.21.2.linux-ppc64le.tar.gz'; \
			sha256='429ae21664ee12fdddc9a04fd0646879da34d81fe3fd316d57250e7fd50e7c6b'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.21.2.linux-riscv64.tar.gz'; \
			sha256='040a6c0978bb4022b36a4c3c6077585ce98295d5eac4195ff15a5a3966904a3b'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.21.2.linux-s390x.tar.gz'; \
			sha256='544c867180bf3384396b0906a7f14f4dc26bb7e78d4b05a8b45557b1b0ce0376'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	build=; \
	if [ -z "$url" ]; then \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
		build=1; \
		url='https://dl.google.com/go/go1.21.2.src.tar.gz'; \
		sha256='45e59de173baec39481854490d665b726cec3e5b159f6b4172e5ec7780b2c201'; \
		echo >&2; \
		echo >&2 "warning: current architecture ($arch) does not have a compatible Go binary release; will be building from source"; \
		echo >&2; \
	fi; \
	\
	wget -O go.tgz.asc "$url.asc"; \
	wget -O go.tgz "$url"; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	\
# https://github.com/golang/go/issues/14739#issuecomment-324767697
	GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
# https://www.google.com/linuxrepositories/
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC  EC91 7721 F63B D38B 4796'; \
# let's also fetch the specific subkey of that key explicitly that we expect "go.tgz.asc" to be signed by, just to make sure we definitely have it
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys '2F52 8D36 D67B 69ED F998  D857 78BD 6547 3CB3 BD13'; \
	gpg --batch --verify go.tgz.asc go.tgz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" go.tgz.asc; \
	\
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ -n "$build" ]; then \
		apk add --no-cache --virtual .build-deps \
			bash \
			gcc \
			go \
			musl-dev \
		; \
		\
		export GOCACHE='/tmp/gocache'; \
		\
		( \
			cd /usr/local/go/src; \
# set GOROOT_BOOTSTRAP + GOHOST* such that we can build Go successfully
			export GOROOT_BOOTSTRAP="$(go env GOROOT)" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
			if [ "${GOARCH:-}" = '386' ]; then \
# https://github.com/golang/go/issues/52919; https://github.com/docker-library/golang/pull/426#issuecomment-1152623837
				export CGO_CFLAGS='-fno-stack-protector'; \
			fi; \
			./make.bash; \
		); \
		\
		apk del --no-network .build-deps; \
		\
# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain
		rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
			"$GOCACHE" \
		; \
	fi; \
	\
	apk del --no-network .fetch-deps; \
	\
	go version

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
