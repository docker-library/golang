#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18

RUN apk add --no-cache ca-certificates

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.21rc2

RUN set -eux; \
	apk add --no-cache --virtual .fetch-deps gnupg; \
	arch="$(apk --print-arch)"; \
	url=; \
	case "$arch" in \
		'x86_64') \
			url='https://dl.google.com/go/go1.21rc2.linux-amd64.tar.gz'; \
			sha256='8fe90332727c606019e80a7368e23f5e65ad59520e45ee4010692f15572e45c6'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.21rc2.linux-armv6l.tar.gz'; \
			sha256='0f82199e49978db858a8ed2c6b8d842b9674fd577c4ab91cc4b6b11672375993'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.21rc2.linux-armv6l.tar.gz'; \
			sha256='0f82199e49978db858a8ed2c6b8d842b9674fd577c4ab91cc4b6b11672375993'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.21rc2.linux-arm64.tar.gz'; \
			sha256='30a6518ca5f816c0fef5b2cc16b960e999b98b16f7d69f995f74236cc00aa292'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.21rc2.linux-386.tar.gz'; \
			sha256='cf330c82e41cf766af5629772600d5ecd3d24faeacdba8ac1f5f33acc6590175'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.21rc2.linux-ppc64le.tar.gz'; \
			sha256='8c3a2674cf57c304ed1a8f4e0a6184ad85fd5760a04dea608fdcaca7ad863027'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.21rc2.linux-riscv64.tar.gz'; \
			sha256='33ea0c09d1f10f034d9e4fbef4eaceb785f3433ba631eaacb01a0af40773b673'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.21rc2.linux-s390x.tar.gz'; \
			sha256='3fd1640c1f4c50dff412643cd61577d53c8241f1f2789605b1ff1048d2b36f95'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	build=; \
	if [ -z "$url" ]; then \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
		build=1; \
		url='https://dl.google.com/go/go1.21rc2.src.tar.gz'; \
		sha256='91596dce22d91f2d7be6d2b49829f39bdd8573e777d95c1b3c6b0d42b613076e'; \
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

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
