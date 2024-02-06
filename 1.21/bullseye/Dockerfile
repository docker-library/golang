#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:bullseye-scm AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.21.7

RUN set -eux; \
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	url=; \
	case "$arch" in \
		'amd64') \
			url='https://dl.google.com/go/go1.21.7.linux-amd64.tar.gz'; \
			sha256='13b76a9b2a26823e53062fa841b07087d48ae2ef2936445dc34c4ae03293702c'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.21.7.linux-armv6l.tar.gz'; \
			sha256='d86d2da4cad1c0ff5fc13677b0b77f26ca8adca48170c140f06b882e83b6e8df'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go1.21.7.linux-arm64.tar.gz'; \
			sha256='a9bc1ccedbfde059f25b3a2ad81ae4cdf21192ae207dfd3ccbbfe99c3749e233'; \
			;; \
		'i386') \
			url='https://dl.google.com/go/go1.21.7.linux-386.tar.gz'; \
			sha256='ecd838b01c28b62d23e0fc806f980de676a6754be53e6bf2f1fe966c12dede15'; \
			;; \
		'mips64el') \
			url='https://dl.google.com/go/go1.21.7.linux-mips64le.tar.gz'; \
			sha256='adf55215880b6157a945a8f247a2cbea9e63766cd297baf68fd575c2cc32a82a'; \
			;; \
		'ppc64el') \
			url='https://dl.google.com/go/go1.21.7.linux-ppc64le.tar.gz'; \
			sha256='48a99ecce9b1e632870c29420088f61cf17a6f0c5bdb3cc821ff5c00e14b1a8a'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.21.7.linux-riscv64.tar.gz'; \
			sha256='dc1c3cb6eadc57130136b3c1dec5ca8af7783c36e0392ebf59073c61e60b24f2'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.21.7.linux-s390x.tar.gz'; \
			sha256='d655022bd82927fbfeb36eb49a3e2af0f3cc18d18882c0f671923da0ec257948'; \
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
		date="$(date -d "@$SOURCE_DATE_EPOCH" '+%Y%m%d%H%M.%S')"; \
		touch -t "$date" /usr/local/go/go.env /usr/local/go; \
	fi; \
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

ENV GOLANG_VERSION 1.21.7

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=build --link /usr/local/go/ /usr/local/go/
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
