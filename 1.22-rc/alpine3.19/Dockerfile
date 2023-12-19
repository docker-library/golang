#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.19

RUN apk add --no-cache ca-certificates

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.22rc1

RUN set -eux; \
	apk add --no-cache --virtual .fetch-deps gnupg; \
	arch="$(apk --print-arch)"; \
	url=; \
	case "$arch" in \
		'x86_64') \
			url='https://dl.google.com/go/go1.22rc1.linux-amd64.tar.gz'; \
			sha256='fbe9d0585b9322d44008f6baf78b391b22f64294338c6ce2b9eb6040d6373c52'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.22rc1.linux-armv6l.tar.gz'; \
			sha256='78e86eb1f449d88692829f1d794cd9f696b66c4f5e25f4ceb4ddd3ad7bee3683'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.22rc1.linux-armv6l.tar.gz'; \
			sha256='78e86eb1f449d88692829f1d794cd9f696b66c4f5e25f4ceb4ddd3ad7bee3683'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.22rc1.linux-arm64.tar.gz'; \
			sha256='d777d6bc3241bcd470603c3af896d1c60ed1d8cc718cf92d0a5d9035b149a827'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.22rc1.linux-386.tar.gz'; \
			sha256='85ea68ef2fbd0d28179a8852401f498cb02dd7a2d688e71e54ee6180a790d105'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.22rc1.linux-ppc64le.tar.gz'; \
			sha256='051d68e1fb9c804db0c5ecf856493ccf7611f6b05424bfe6d6a03ce03e5dbb24'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.22rc1.linux-riscv64.tar.gz'; \
			sha256='f7c9d98683f52004bc9942a6ac4ae628f89070446f24ad5451404ad7ee27682a'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.22rc1.linux-s390x.tar.gz'; \
			sha256='29e6b990a47cb3942e72208e91e370b3620119d0a7dcb2a58de57bde7716fc2b'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	build=; \
	if [ -z "$url" ]; then \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
		build=1; \
		url='https://dl.google.com/go/go1.22rc1.src.tar.gz'; \
		sha256='9aecbb8ebae41b93ea26ef5b014296fbbe70a07630249c0d8a275df3bd4d26ea'; \
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
	elif [ "$arch" = 'armv7' ]; then \
		[ -s /usr/local/go/go.env ]; \
		before="$(go env GOARM)"; [ "$before" != '7' ]; \
		{ \
			echo; \
			echo '# https://github.com/docker-library/golang/issues/494'; \
			echo 'GOARM=7'; \
		} >> /usr/local/go/go.env; \
		after="$(go env GOARM)"; [ "$after" = '7' ]; \
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
