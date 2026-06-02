#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.22 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.26.4

RUN set -eux; \
	now="$(date '+%s')"; \
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
			url='https://dl.google.com/go/go1.26.4.linux-amd64.tar.gz'; \
			sha256='1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.26.4.linux-armv6l.tar.gz'; \
			sha256='8db458e995f18a9427a745cefe7a3323962fa2548c4715148963311f300d3b1a'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.26.4.linux-armv6l.tar.gz'; \
			sha256='8db458e995f18a9427a745cefe7a3323962fa2548c4715148963311f300d3b1a'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.26.4.linux-arm64.tar.gz'; \
			sha256='ef758ae7c6cf9267c9c0ef080b8965f453d89ab2d25d9eb22de4405925238768'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.26.4.linux-386.tar.gz'; \
			sha256='5ca0982791791559d11a0eba939617a94c3f37c21aa514a55c415b9167efc658'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.26.4.linux-ppc64le.tar.gz'; \
			sha256='53f49b8c7eace2d30389327b4a516b13321f90377fdf5929a6b63174609bc22e'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.26.4.linux-riscv64.tar.gz'; \
			sha256='2b9ba137baaa3031fd74330cb36ab54c5abe380867ca9fbab7c552f3db740555'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.26.4.linux-s390x.tar.gz'; \
			sha256='1e12a2318f3dd4c57027c865f6cb51f5d1e36b02d10f3e6316ce7b61a27b3ca1'; \
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
	touchy="$(date -d "@$SOURCE_DATE_EPOCH" '+%Y%m%d%H%M.%S')"; \
# for logging validation/edification
	date --date "@$SOURCE_DATE_EPOCH" --rfc-2822; \
# sanity check (detected value should be older than our wall clock)
	[ "$SOURCE_DATE_EPOCH" -lt "$now" ]; \
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
		touch -t "$touchy" /usr/local/go/go.env /usr/local/go; \
	fi; \
	\
# ideally at this point, we would just "COPY --link ... /usr/local/go/ /usr/local/go/" but BuildKit insists on creating the parent directories (perhaps related to https://github.com/opencontainers/image-spec/pull/970), and does so with unreproducible timestamps, so we instead create a whole new "directory tree" that we can "COPY --link" to accomplish what we want
	mkdir /target /target/usr /target/usr/local; \
	mv -vT /usr/local/go /target/usr/local/go; \
	ln -svfT /target/usr/local/go /usr/local/go; \
	touch -t "$touchy" /target/usr/local /target/usr /target; \
	\
	apk del --no-network .fetch-deps; \
	\
# smoke test
	go version; \
# make sure our reproducibile timestamp is probably still correct (best-effort inline reproducibility test)
	epoch="$(stat -c '%Y' /target/usr/local/go)"; \
	[ "$SOURCE_DATE_EPOCH" = "$epoch" ]; \
	find /target -newer /target/usr/local/go -exec sh -c 'ls -ld "$@" && exit "$#"' -- '{}' +

FROM alpine:3.22

RUN apk add --no-cache ca-certificates

ENV GOLANG_VERSION 1.26.4

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# (see notes above about "COPY --link")
COPY --from=build --link /target/ /
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
