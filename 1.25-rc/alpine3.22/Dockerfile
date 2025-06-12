#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.22 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.25rc1

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
			url='https://dl.google.com/go/go1.25rc1.linux-amd64.tar.gz'; \
			sha256='7588a720e243e4672e0dc1c7942ec7592d480a80440fa2829be8b22c9c44a5b7'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.25rc1.linux-armv6l.tar.gz'; \
			sha256='96a18398bc2bbbb2a144e0f30c431a1508351d43c1b1194c7647ca4a967dbc69'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.25rc1.linux-armv6l.tar.gz'; \
			sha256='96a18398bc2bbbb2a144e0f30c431a1508351d43c1b1194c7647ca4a967dbc69'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.25rc1.linux-arm64.tar.gz'; \
			sha256='ee0b82bc1421c66f3f322a214218b423beddb64182e0105dbff142e777e96fc1'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.25rc1.linux-386.tar.gz'; \
			sha256='4fb3aee891b70edee4423fb457546a30341a7b112c38594af4ee5f6db77ac376'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.25rc1.linux-ppc64le.tar.gz'; \
			sha256='1ffd0793a1288854e73096c673597854d30d065f18dc5803f39b8c729aa65f7b'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.25rc1.linux-riscv64.tar.gz'; \
			sha256='3e5fbc8fdc44a8bbd1b2393a6cc369eb6f43f99d424e0b01b1e38977989239fd'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.25rc1.linux-s390x.tar.gz'; \
			sha256='bfcea7cc93ab874185ef6c66a66dacc34ab01dbd03c4d0e5aad3d360c1a6c324'; \
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

ENV GOLANG_VERSION 1.25rc1

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# (see notes above about "COPY --link")
COPY --from=build --link /target/ /
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
