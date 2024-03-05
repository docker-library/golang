#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.21.8

RUN set -eux; \
	apk add --no-cache --virtual .fetch-deps \
		ca-certificates \
		gnupg \
# busybox's "tar" doesn't handle directory mtime correctly, so our SOURCE_DATE_EPOCH lookup doesn't work (the mtime of "/usr/local/go" always ends up being the extraction timestamp)
		tar \
	; \
	arch="$(apk --print-arch)"; \
	url=; \
	case "$arch" in \
		'x86_64') \
			url='https://dl.google.com/go/go1.21.8.linux-amd64.tar.gz'; \
			sha256='538b3b143dc7f32b093c8ffe0e050c260b57fc9d57a12c4140a639a8dd2b4e4f'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.21.8.linux-armv6l.tar.gz'; \
			sha256='99f836c27807334409870930481ed8453cda7a06d6319853ee74fc924e352a47'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.21.8.linux-armv6l.tar.gz'; \
			sha256='99f836c27807334409870930481ed8453cda7a06d6319853ee74fc924e352a47'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.21.8.linux-arm64.tar.gz'; \
			sha256='3c19113c686ffa142e9159de1594c952dee64d5464965142d222eab3a81f1270'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.21.8.linux-386.tar.gz'; \
			sha256='b25f37fcfc171514497f4a7ebc2e8cb945ee89cf142cd677d2fe5e79001cfa09'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.21.8.linux-ppc64le.tar.gz'; \
			sha256='e073dc1e0a94e4b43b1369fab8b5acc30e80cdbed99352a083681929225622fc'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.21.8.linux-riscv64.tar.gz'; \
			sha256='fe3e40706c83cf011e9e6c2a3d26feb2eb50e5c89af7d23ef05b72930e9dddf5'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.21.8.linux-s390x.tar.gz'; \
			sha256='7df2608e412de08df9cf3a1637a068f0dcbf28c3cc25659b4dfd7960c6fe5b3d'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
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
# save the timestamp from the tarball so we can restore it for reproducibility, if necessary (see below)
	SOURCE_DATE_EPOCH="$(stat -c '%Y' /usr/local/go)"; \
	export SOURCE_DATE_EPOCH; \
# for logging validation/edification
	date --date "@$SOURCE_DATE_EPOCH" --rfc-2822; \
	\
	if [ "$arch" = 'armv7' ]; then \
		[ -s /usr/local/go/go.env ]; \
		before="$(go env GOARM)"; [ "$before" != '7' ]; \
		{ \
			echo; \
			echo '# https://github.com/docker-library/golang/issues/494'; \
			echo 'GOARM=7'; \
		} >> /usr/local/go/go.env; \
		after="$(go env GOARM)"; [ "$after" = '7' ]; \
# (re-)clamp timestamp for reproducibility (allows "COPY --link" to be more clever/useful)
		date="$(date -d "@$SOURCE_DATE_EPOCH" '+%Y%m%d%H%M.%S')"; \
		touch -t "$date" /usr/local/go/go.env /usr/local/go; \
	fi; \
	\
	apk del --no-network .fetch-deps; \
	\
# smoke test
	go version; \
# make sure our reproducibile timestamp is probably still correct (best-effort inline reproducibility test)
	epoch="$(stat -c '%Y' /usr/local/go)"; \
	[ "$SOURCE_DATE_EPOCH" = "$epoch" ]

FROM alpine:3.18

RUN apk add --no-cache ca-certificates

ENV GOLANG_VERSION 1.21.8

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=build --link /usr/local/go/ /usr/local/go/
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
