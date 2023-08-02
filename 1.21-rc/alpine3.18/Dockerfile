#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18

RUN apk add --no-cache ca-certificates

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.21rc4

RUN set -eux; \
	apk add --no-cache --virtual .fetch-deps gnupg; \
	arch="$(apk --print-arch)"; \
	url=; \
	case "$arch" in \
		'x86_64') \
			url='https://dl.google.com/go/go1.21rc4.linux-amd64.tar.gz'; \
			sha256='c05c7b5030c4785dd3b4125bdb9eb631a840ea7347f4219b299de308021ac15b'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.21rc4.linux-armv6l.tar.gz'; \
			sha256='43b5781d1f044c5142b5ef4e10982d32b53aa5acbbbc1aa3c651c16ca04ba29a'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.21rc4.linux-armv6l.tar.gz'; \
			sha256='43b5781d1f044c5142b5ef4e10982d32b53aa5acbbbc1aa3c651c16ca04ba29a'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.21rc4.linux-arm64.tar.gz'; \
			sha256='35961f9151b865df9947bc1e154b6f490c2c7b3efae2b44d984abc3f8c9b2be2'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.21rc4.linux-386.tar.gz'; \
			sha256='9e72450b6ab781ee4e7bcf468b476e94164947124d88255dd617e9a36b222d37'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.21rc4.linux-ppc64le.tar.gz'; \
			sha256='43455c6d103364d2b43ba786f4a603f8d15a03255277a0baebdb3b9bb511a59c'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.21rc4.linux-riscv64.tar.gz'; \
			sha256='45bf99fc0986b7eddb5317f9c2742065501b008b61e08c7cf442a13fcc2c2b81'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.21rc4.linux-s390x.tar.gz'; \
			sha256='a94b45f34f7945839826a89660422bf619a81b9cb1b726823425ff956244417d'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	build=; \
	if [ -z "$url" ]; then \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
		build=1; \
		url='https://dl.google.com/go/go1.21rc4.src.tar.gz'; \
		sha256='2324f20f11112aec3e5d5e428d046861a34e4f99de0ab82a8d914d26b8fb01fd'; \
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
