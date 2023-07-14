#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.17

RUN apk add --no-cache ca-certificates

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.21rc3

RUN set -eux; \
	apk add --no-cache --virtual .fetch-deps gnupg; \
	arch="$(apk --print-arch)"; \
	url=; \
	case "$arch" in \
		'x86_64') \
			url='https://dl.google.com/go/go1.21rc3.linux-amd64.tar.gz'; \
			sha256='b5e3a28d10ba1109cf0549237f2739284a0db2ce6bdc76cd03c4b26304c1a921'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.21rc3.linux-armv6l.tar.gz'; \
			sha256='928b43cde3485005d30dad132142bea733a7227a3942d9832b896d9282ef8dc1'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.21rc3.linux-armv6l.tar.gz'; \
			sha256='928b43cde3485005d30dad132142bea733a7227a3942d9832b896d9282ef8dc1'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.21rc3.linux-arm64.tar.gz'; \
			sha256='8891193758aed49daedff3f519b12f81e15a947170437a9109e3ff8c11d7f7e2'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.21rc3.linux-386.tar.gz'; \
			sha256='96a0b0fb4b65db37a265d5758d007ad25c6ba9d29470c0012c6cb9c714be813f'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.21rc3.linux-ppc64le.tar.gz'; \
			sha256='10af108730b75174cd1db9919781de9119018a818c02588e2299554378428c6a'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.21rc3.linux-riscv64.tar.gz'; \
			sha256='9b341bbea1ba2c75c06d1b903a7f398ed4b8e6ed31557f64397728d16068bfaf'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.21rc3.linux-s390x.tar.gz'; \
			sha256='c6dc855976b74f21168f413be46d448de1fbb545cc9fb47895c4b62581e33724'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	build=; \
	if [ -z "$url" ]; then \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
		build=1; \
		url='https://dl.google.com/go/go1.21rc3.src.tar.gz'; \
		sha256='9de96a2f15196a9c69cb9ab122c9c2aaecca30ec9448caa71543eaeb19ca91ab'; \
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
