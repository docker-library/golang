#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:bullseye-scm AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.22.12

RUN set -eux; \
	now="$(date '+%s')"; \
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	url=; \
	case "$arch" in \
		'amd64') \
			url='https://dl.google.com/go/go1.22.12.linux-amd64.tar.gz'; \
			sha256='4fa4f869b0f7fc6bb1eb2660e74657fbf04cdd290b5aef905585c86051b34d43'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.22.12.linux-armv6l.tar.gz'; \
			sha256='bcd678461bb74cda217fb5aa3cc914b2021be6d828f0c6fb4e3a36c3d7312acb'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go1.22.12.linux-arm64.tar.gz'; \
			sha256='fd017e647ec28525e86ae8203236e0653242722a7436929b1f775744e26278e7'; \
			;; \
		'i386') \
			url='https://dl.google.com/go/go1.22.12.linux-386.tar.gz'; \
			sha256='40d4c297bc2e964e9c96fe79bb323dce79b77b8b103fc7cc52e0a87c7849890f'; \
			;; \
		'mips64el') \
			url='https://dl.google.com/go/go1.22.12.linux-mips64le.tar.gz'; \
			sha256='2d473895f9c1dc8c86d51eb13f8ca49b7eea46010759fd71efed3eecacf5335b'; \
			;; \
		'ppc64el') \
			url='https://dl.google.com/go/go1.22.12.linux-ppc64le.tar.gz'; \
			sha256='9573d30003b0796717a99d9e2e96c48fddd4fc0f29d840f212c503b03d7de112'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.22.12.linux-riscv64.tar.gz'; \
			sha256='f03a084aabc812fdc15b29acd5e1ee18e13b3c80be22aec43990119afcaf4947'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.22.12.linux-s390x.tar.gz'; \
			sha256='e1b20935cc790fdc4c48c0e3e6dd11be57ac09e4eb302ba2cdf146276468b346'; \
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

FROM buildpack-deps:bullseye-scm

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
	rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.22.12

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# (see notes above about "COPY --link")
COPY --from=build --link /target/ /
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
