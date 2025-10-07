#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:trixie-scm AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.24.8

RUN set -eux; \
	now="$(date '+%s')"; \
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	url=; \
	case "$arch" in \
		'amd64') \
			url='https://dl.google.com/go/go1.24.8.linux-amd64.tar.gz'; \
			sha256='6842c516ca66c89d648a7f1dbe28e28c47b61b59f8f06633eb2ceb1188e9251d'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.24.8.linux-armv6l.tar.gz'; \
			sha256='3ed8537300ab22449885a43d2931336a571df72c5433d2db4377fe7e2d5e83db'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go1.24.8.linux-arm64.tar.gz'; \
			sha256='38ac33b4cfa41e8a32132de7a87c6db49277ab5c0de1412512484db1ed77637e'; \
			;; \
		'i386') \
			url='https://dl.google.com/go/go1.24.8.linux-386.tar.gz'; \
			sha256='13099b083f9b42a02acf1b8ba825a72c25c2ad4fd5ad53662bd2256bd977f817'; \
			;; \
		'mips64el') \
			url='https://dl.google.com/go/go1.24.8.linux-mips64le.tar.gz'; \
			sha256='4eed20ef7f63d4adea657e767ab1912d1f3789354e419663c08f73727806e0dd'; \
			;; \
		'ppc64el') \
			url='https://dl.google.com/go/go1.24.8.linux-ppc64le.tar.gz'; \
			sha256='f2cb4af6804a0bfd3591b30c89b599a44aef1b48bf23ad46076ce5d52f92f17a'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.24.8.linux-riscv64.tar.gz'; \
			sha256='925871d9f580a579ff16d7fe7861ac6ca4222636da93da80ca72d16b794ef336'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.24.8.linux-s390x.tar.gz'; \
			sha256='dc33c46c0b4f93e2f370bc0f6eb1b6ed57a3b2920ec97df526d6376682a33d82'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	\
	wget -O go.tgz.asc "$url.asc"; \
	wget -O go.tgz "$url" --progress=dot:giga; \
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
	if [ "$arch" = 'armhf' ]; then \
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
# smoke test
	go version; \
# make sure our reproducibile timestamp is probably still correct (best-effort inline reproducibility test)
	epoch="$(stat -c '%Y' /target/usr/local/go)"; \
	[ "$SOURCE_DATE_EPOCH" = "$epoch" ]; \
	find /target -newer /target/usr/local/go -exec sh -c 'ls -ld "$@" && exit "$#"' -- '{}' +

FROM buildpack-deps:trixie-scm

# install cgo-related dependencies
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	; \
# go depends on "gold" explicitly on arm64
# https://github.com/docker-library/golang/issues/570 (go depends on "gold" explicitly on arm64)
# https://github.com/golang/go/issues/22040
# ... and as of trixie, "gold" is removed from the "binutils" package:
# > WARNING: gold is being removed from binutils, and is deprecated upstream.
# (and available as "binutils-gold" which is also a virtual on bookworm so we can reasonably be explicit everywhere)
	dpkgArch="$(dpkg --print-architecture)"; \
	if [ "$dpkgArch" = 'arm64' ]; then \
		apt-get install -y --no-install-recommends binutils-gold; \
	fi; \
	rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.24.8

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# (see notes above about "COPY --link")
COPY --from=build --link /target/ /
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
