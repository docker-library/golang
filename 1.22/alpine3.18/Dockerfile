#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.22.2

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
			url='https://dl.google.com/go/go1.22.2.linux-amd64.tar.gz'; \
			sha256='5901c52b7a78002aeff14a21f93e0f064f74ce1360fce51c6ee68cd471216a17'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.22.2.linux-armv6l.tar.gz'; \
			sha256='9243dfafde06e1efe24d59df6701818e6786b4adfdf1191098050d6d023c5369'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.22.2.linux-armv6l.tar.gz'; \
			sha256='9243dfafde06e1efe24d59df6701818e6786b4adfdf1191098050d6d023c5369'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.22.2.linux-arm64.tar.gz'; \
			sha256='36e720b2d564980c162a48c7e97da2e407dfcc4239e1e58d98082dfa2486a0c1'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.22.2.linux-386.tar.gz'; \
			sha256='586d9eb7fe0489ab297ad80dd06414997df487c5cf536c490ffeaa8d8f1807a7'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.22.2.linux-ppc64le.tar.gz'; \
			sha256='251a8886c5113be6490bdbb955ddee98763b49c9b1bf4c8364c02d3b482dab00'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.22.2.linux-riscv64.tar.gz'; \
			sha256='2e0447ed3294729232e012898a43145defaf2ffbfece2e934edda8bd2775c400'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.22.2.linux-s390x.tar.gz'; \
			sha256='2b39019481c28c560d65e9811a478ae10e3ef765e0f59af362031d386a71bfef'; \
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

ENV GOLANG_VERSION 1.22.2

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=build --link /usr/local/go/ /usr/local/go/
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
