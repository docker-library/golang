#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.22.3

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
			url='https://dl.google.com/go/go1.22.3.linux-amd64.tar.gz'; \
			sha256='8920ea521bad8f6b7bc377b4824982e011c19af27df88a815e3586ea895f1b36'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.22.3.linux-armv6l.tar.gz'; \
			sha256='f2bacad20cd2b96f23a86d4826525d42b229fd431cc6d0dec61ff3bc448ef46e'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.22.3.linux-armv6l.tar.gz'; \
			sha256='f2bacad20cd2b96f23a86d4826525d42b229fd431cc6d0dec61ff3bc448ef46e'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.22.3.linux-arm64.tar.gz'; \
			sha256='6c33e52a5b26e7aa021b94475587fce80043a727a54ceb0eee2f9fc160646434'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.22.3.linux-386.tar.gz'; \
			sha256='fefba30bb0d3dd1909823ee38c9f1930c3dc5337a2ac4701c2277a329a386b57'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.22.3.linux-ppc64le.tar.gz'; \
			sha256='04b7b05283de30dd2da20bf3114b2e22cc727938aed3148babaf35cc951051ac'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.22.3.linux-riscv64.tar.gz'; \
			sha256='d4992d4a85696e3f1de06cefbfc2fd840c9c6695d77a0f35cfdc4e28b2121c20'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.22.3.linux-s390x.tar.gz'; \
			sha256='2aba796417a69be5f3ed489076bac79c1c02b36e29422712f9f3bf51da9cf2d4'; \
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

ENV GOLANG_VERSION 1.22.3

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=build --link /usr/local/go/ /usr/local/go/
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
