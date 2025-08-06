#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.22 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.25rc3

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
			url='https://dl.google.com/go/go1.25rc3.linux-amd64.tar.gz'; \
			sha256='e6c08a140ae7c28770eeb246934981fe5095ecc92ec232571497c22a7588960e'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.25rc3.linux-armv6l.tar.gz'; \
			sha256='82d5157bfe441100f96601da77e1951301904a36d85d6497d9f524544c83bf0f'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.25rc3.linux-armv6l.tar.gz'; \
			sha256='82d5157bfe441100f96601da77e1951301904a36d85d6497d9f524544c83bf0f'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.25rc3.linux-arm64.tar.gz'; \
			sha256='5b07f421b2a9b477da5ba3cc62e24a85fb28b2f83f6db081896bcf0d2e76cfd2'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.25rc3.linux-386.tar.gz'; \
			sha256='337d124f69d81bbfd434fae0e25466f13245c6386d87e783d1fcf14a3261eb9b'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.25rc3.linux-ppc64le.tar.gz'; \
			sha256='ea1f0d96e903f97ab7e805ed072b41117ff80dc6f2113b846067e7e7563cf88d'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.25rc3.linux-riscv64.tar.gz'; \
			sha256='ad8d5f24a60731ec0e32b195f0db8c642c3ff7983902ab03d577191f33e134b5'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.25rc3.linux-s390x.tar.gz'; \
			sha256='ee2e34bc2bc3dc7f90cb51787512221c2a3032dd4358604e0273e1cf76b076b9'; \
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

ENV GOLANG_VERSION 1.25rc3

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# (see notes above about "COPY --link")
COPY --from=build --link /target/ /
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
