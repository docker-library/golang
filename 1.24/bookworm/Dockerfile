#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:bookworm-scm AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.24.11

RUN set -eux; \
	now="$(date '+%s')"; \
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	url=; \
	case "$arch" in \
		'amd64') \
			url='https://dl.google.com/go/go1.24.11.linux-amd64.tar.gz'; \
			sha256='bceca00afaac856bc48b4cc33db7cd9eb383c81811379faed3bdbc80edb0af65'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.24.11.linux-armv6l.tar.gz'; \
			sha256='24d712a7e8ea2f429c05bc67287249e0291f2fe0ea6d6ff268f11b7343ad0f47'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go1.24.11.linux-arm64.tar.gz'; \
			sha256='beaf0f51cbe0bd71b8289b2b6fa96c0b11cd86aa58672691ef2f1de88eb621de'; \
			;; \
		'i386') \
			url='https://dl.google.com/go/go1.24.11.linux-386.tar.gz'; \
			sha256='bb702d0b67759724dccee1825828e8bae0b5199e3295cac5a98a81f3098fa64a'; \
			;; \
		'mips64el') \
			url='https://dl.google.com/go/go1.24.11.linux-mips64le.tar.gz'; \
			sha256='c0274255613b85e2ba45e210e8f07995d51a048f11c7f0b9128dc177472692b3'; \
			;; \
		'ppc64el') \
			url='https://dl.google.com/go/go1.24.11.linux-ppc64le.tar.gz'; \
			sha256='f770d0c5d7e7e2edb030133ac7854d9204f4e954e79a176e81362ffedf6ea34c'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.24.11.linux-riscv64.tar.gz'; \
			sha256='9db9ba8e6b60f3662f55ed78b128175edbe8b9480e657126a5b8f5043ee1e38c'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.24.11.linux-s390x.tar.gz'; \
			sha256='5955ddda3445b2cbfd81b8772044084911f55d0baeb32414da0411f6a377a2d4'; \
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

FROM buildpack-deps:bookworm-scm

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

ENV GOLANG_VERSION 1.24.11

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# (see notes above about "COPY --link")
COPY --from=build --link /target/ /
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
