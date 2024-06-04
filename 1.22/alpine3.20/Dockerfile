#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.20 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.22.4

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
			url='https://dl.google.com/go/go1.22.4.linux-amd64.tar.gz'; \
			sha256='ba79d4526102575196273416239cca418a651e049c2b099f3159db85e7bade7d'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.22.4.linux-armv6l.tar.gz'; \
			sha256='e2b143fbacbc9cbd448e9ef41ac3981f0488ce849af1cf37e2341d09670661de'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.22.4.linux-armv6l.tar.gz'; \
			sha256='e2b143fbacbc9cbd448e9ef41ac3981f0488ce849af1cf37e2341d09670661de'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.22.4.linux-arm64.tar.gz'; \
			sha256='a8e177c354d2e4a1b61020aca3562e27ea3e8f8247eca3170e3fa1e0c2f9e771'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.22.4.linux-386.tar.gz'; \
			sha256='47a2a8d249a91eb8605c33bceec63aedda0441a43eac47b4721e3975ff916cec'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.22.4.linux-ppc64le.tar.gz'; \
			sha256='a3e5834657ef92523f570f798fed42f1f87bc18222a16815ec76b84169649ec4'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.22.4.linux-riscv64.tar.gz'; \
			sha256='56a827ff7dc6245bcd7a1e9288dffaa1d8b0fd7468562264c1523daf3b4f1b4a'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.22.4.linux-s390x.tar.gz'; \
			sha256='7590c3e278e2dc6040aae0a39da3ca1eb2e3921673a7304cc34d588c45889eec'; \
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

FROM alpine:3.20

RUN apk add --no-cache ca-certificates

ENV GOLANG_VERSION 1.22.4

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=build --link /usr/local/go/ /usr/local/go/
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
