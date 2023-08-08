#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18

RUN apk add --no-cache ca-certificates

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.21.0

RUN set -eux; \
	apk add --no-cache --virtual .fetch-deps gnupg; \
	arch="$(apk --print-arch)"; \
	url=; \
	case "$arch" in \
		'x86_64') \
			url='https://dl.google.com/go/go1.21.0.linux-amd64.tar.gz'; \
			sha256='d0398903a16ba2232b389fb31032ddf57cac34efda306a0eebac34f0965a0742'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.21.0.linux-armv6l.tar.gz'; \
			sha256='e377a0004957c8c560a3ff99601bce612330a3d95ba3b0a2ae144165fc87deb1'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.21.0.linux-armv6l.tar.gz'; \
			sha256='e377a0004957c8c560a3ff99601bce612330a3d95ba3b0a2ae144165fc87deb1'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.21.0.linux-arm64.tar.gz'; \
			sha256='f3d4548edf9b22f26bbd49720350bbfe59d75b7090a1a2bff1afad8214febaf3'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.21.0.linux-386.tar.gz'; \
			sha256='0e6f378d9b072fab0a3d9ff4d5e990d98487d47252dba8160015a61e6bd0bcba'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.21.0.linux-ppc64le.tar.gz'; \
			sha256='e938ffc81d8ebe5efc179240960ba22da6a841ff05d5cab7ce2547112b14a47f'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.21.0.linux-riscv64.tar.gz'; \
			sha256='87b21c06573617842ca9e00b954bc9f534066736a0778eae594ac54b45a9e8b7'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.21.0.linux-s390x.tar.gz'; \
			sha256='be7338df8e5d5472dfa307b0df2b446d85d001b0a2a3cdb1a14048d751b70481'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	build=; \
	if [ -z "$url" ]; then \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
		build=1; \
		url='https://dl.google.com/go/go1.21.0.src.tar.gz'; \
		sha256='818d46ede85682dd551ad378ef37a4d247006f12ec59b5b755601d2ce114369a'; \
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
