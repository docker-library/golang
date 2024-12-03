#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.20 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.23.4

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
			url='https://dl.google.com/go/go1.23.4.linux-amd64.tar.gz'; \
			sha256='6924efde5de86fe277676e929dc9917d466efa02fb934197bc2eba35d5680971'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.23.4.linux-armv6l.tar.gz'; \
			sha256='1f1dda0dc7ce0b2295f57258ec5ef0803fd31b9ed0aa20e2e9222334e5755de1'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.23.4.linux-armv6l.tar.gz'; \
			sha256='1f1dda0dc7ce0b2295f57258ec5ef0803fd31b9ed0aa20e2e9222334e5755de1'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.23.4.linux-arm64.tar.gz'; \
			sha256='16e5017863a7f6071363782b1b8042eb12c6ca4f4cd71528b2123f0a1275b13e'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.23.4.linux-386.tar.gz'; \
			sha256='4a4a0e7587ef8c8a326439b957027f2791795e2d29d4ae3885b4091a48f843bc'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.23.4.linux-ppc64le.tar.gz'; \
			sha256='65a303ef51e48ff77e004a6a5b4db6ce59495cd59c6af51b54bf4f786c01a1b9'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.23.4.linux-riscv64.tar.gz'; \
			sha256='7c40e9e0d722cef14ede765159ba297f4c6e3093bb106f10fbccf8564780049a'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.23.4.linux-s390x.tar.gz'; \
			sha256='74aab82bf4eca7c26c830a5b0e2a31d193a4d5ba47045526b92473cc7188d7d7'; \
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

FROM alpine:3.20

RUN apk add --no-cache ca-certificates

ENV GOLANG_VERSION 1.23.4

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# (see notes above about "COPY --link")
COPY --from=build --link /target/ /
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
