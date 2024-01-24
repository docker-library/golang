#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:bullseye-scm AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.22rc2

RUN set -eux; \
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	url=; \
	case "$arch" in \
		'amd64') \
			url='https://dl.google.com/go/go1.22rc2.linux-amd64.tar.gz'; \
			sha256='f811e7ee8f6dee3d162179229f96a64a467c8c02a5687fac5ceaadcf3948c818'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.22rc2.linux-armv6l.tar.gz'; \
			sha256='2b5b4ba2f116dcd147cfd3b1ec77efdcedff230f612bf9e6c971efb58262f709'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go1.22rc2.linux-arm64.tar.gz'; \
			sha256='bf18dc64a396948f97df79a3d73176dbaa7d69341256a1ff1067fd7ec5f79295'; \
			;; \
		'i386') \
			url='https://dl.google.com/go/go1.22rc2.linux-386.tar.gz'; \
			sha256='15321745f1e22a4930bdbf53c456c3aab42204c35c9a0dec4bbe1c641518e502'; \
			;; \
		'mips64el') \
			url='https://dl.google.com/go/go1.22rc2.linux-mips64le.tar.gz'; \
			sha256='d52d63c45b479ad31f44bdee2e5dfee9e2afce9d42a61c5ac453cb0214b6bd13'; \
			;; \
		'ppc64el') \
			url='https://dl.google.com/go/go1.22rc2.linux-ppc64le.tar.gz'; \
			sha256='6f5aab8f36732d5d4b92ca6c96c9b8fa188b561b339740d52facab59a468c1e9'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.22rc2.linux-riscv64.tar.gz'; \
			sha256='1b146b19a46a010e263369a72498356447ba0f71f608cb90af01729d00529f40'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.22rc2.linux-s390x.tar.gz'; \
			sha256='12c9438147094fe33d99ee70d85c8fad1894b643aa0c6d355034fadac2fb7cfd'; \
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
# for logging validation/edification
	date --date "@$SOURCE_DATE_EPOCH" --rfc-2822; \
	\
# smoke test
	go version; \
# make sure our reproducibile timestamp is probably still correct (best-effort inline reproducibility test)
	epoch="$(stat -c '%Y' /usr/local/go)"; \
	[ "$SOURCE_DATE_EPOCH" = "$epoch" ]

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

ENV GOLANG_VERSION 1.22rc2

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=build --link /usr/local/go/ /usr/local/go/
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
