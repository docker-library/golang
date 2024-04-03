#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.21.9

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
			url='https://dl.google.com/go/go1.21.9.linux-amd64.tar.gz'; \
			sha256='f76194c2dc607e0df4ed2e7b825b5847cb37e34fc70d780e2f6c7e805634a7ea'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.21.9.linux-armv6l.tar.gz'; \
			sha256='3d53e0fc659a983bbca3ffa373fab26093d8b1d94198a503be19003a1d73ffb3'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.21.9.linux-armv6l.tar.gz'; \
			sha256='3d53e0fc659a983bbca3ffa373fab26093d8b1d94198a503be19003a1d73ffb3'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.21.9.linux-arm64.tar.gz'; \
			sha256='4d169d9cf3dde1692b81c0fd9484fa28d8bc98f672d06bf9db9c75ada73c5fbc'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.21.9.linux-386.tar.gz'; \
			sha256='a8ba72a03dd7e6e5b8827754153b0dc335361343535b733d666c458e30996b4a'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.21.9.linux-ppc64le.tar.gz'; \
			sha256='6eadde4149c36dae7d9a9bd9385285db1d0e2988350822f4c72a5eb11ffbfffc'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.21.9.linux-riscv64.tar.gz'; \
			sha256='b92dcc990298d68652e28f3bec57824de99a328b8e584a31490b96fe4bd973c5'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.21.9.linux-s390x.tar.gz'; \
			sha256='05daee44fc4771b2a2471b678a812de2488f05110976faeb8bbbae740e01e7ae'; \
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

ENV GOLANG_VERSION 1.21.9

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=build --link /usr/local/go/ /usr/local/go/
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
