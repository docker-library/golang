#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.19 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.21.10

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
			url='https://dl.google.com/go/go1.21.10.linux-amd64.tar.gz'; \
			sha256='e330e5d977bf4f3bdc157bc46cf41afa5b13d66c914e12fd6b694ccda65fcf92'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.21.10.linux-armv6l.tar.gz'; \
			sha256='15af2bcf7c916895f3e4bc16fb94d4ddfbe9ec6ba2b3e096679f4837dd6a72ae'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.21.10.linux-armv6l.tar.gz'; \
			sha256='15af2bcf7c916895f3e4bc16fb94d4ddfbe9ec6ba2b3e096679f4837dd6a72ae'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.21.10.linux-arm64.tar.gz'; \
			sha256='428e0b9ecab5762b7c2be000ad1be6f432dccfcd99bb8b8aeeb757d987bfda9d'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.21.10.linux-386.tar.gz'; \
			sha256='06492fbb0bf06689dbab638a2d70e223c59a27bbd366219d011287b72747a38a'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.21.10.linux-ppc64le.tar.gz'; \
			sha256='069869a483e1e4823dd125ef1a30c2f4c4be7c290e50ed3b4bb0e78614c1e69c'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.21.10.linux-riscv64.tar.gz'; \
			sha256='710dcbe80e967a1a99b8021392c5d5fa052bd8e9dd6b402c973550b3738b1eda'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.21.10.linux-s390x.tar.gz'; \
			sha256='527ad992ec891626e5a46406a89ad877e1a547cca9ecf93542eb0595261e5080'; \
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

FROM alpine:3.19

RUN apk add --no-cache ca-certificates

ENV GOLANG_VERSION 1.21.10

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=build --link /usr/local/go/ /usr/local/go/
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
