#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.22.1

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
			url='https://dl.google.com/go/go1.22.1.linux-amd64.tar.gz'; \
			sha256='aab8e15785c997ae20f9c88422ee35d962c4562212bb0f879d052a35c8307c7f'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.22.1.linux-armv6l.tar.gz'; \
			sha256='8cb7a90e48c20daed39a6ac8b8a40760030ba5e93c12274c42191d868687c281'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.22.1.linux-armv6l.tar.gz'; \
			sha256='8cb7a90e48c20daed39a6ac8b8a40760030ba5e93c12274c42191d868687c281'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.22.1.linux-arm64.tar.gz'; \
			sha256='e56685a245b6a0c592fc4a55f0b7803af5b3f827aaa29feab1f40e491acf35b8'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.22.1.linux-386.tar.gz'; \
			sha256='8484df36d3d40139eaf0fe5e647b006435d826cc12f9ae72973bf7ec265e0ae4'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.22.1.linux-ppc64le.tar.gz'; \
			sha256='ac775e19d93cc1668999b77cfe8c8964abfbc658718feccfe6e0eb87663cd668'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.22.1.linux-riscv64.tar.gz'; \
			sha256='77f7c8d2a8ea10c413c1f86c1c42001cd98bf428239cabceda2cdaff2cf29330'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.22.1.linux-s390x.tar.gz'; \
			sha256='7bb7dd8e10f95c9a4cc4f6bef44c816a6e7c9e03f56ac6af6efbb082b19b379f'; \
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

ENV GOLANG_VERSION 1.22.1

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=build --link /usr/local/go/ /usr/local/go/
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
