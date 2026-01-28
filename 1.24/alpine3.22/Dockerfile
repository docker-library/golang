#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.22 AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.24.13

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
			url='https://dl.google.com/go/go1.24.13.linux-amd64.tar.gz'; \
			sha256='1fc94b57134d51669c72173ad5d49fd62afb0f1db9bf3f798fd98ee423f8d730'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.24.13.linux-armv6l.tar.gz'; \
			sha256='a26b1e54c0fe7b0babc79716a89b830f1cde54f6c6f914a9995d3f0d0bdd0242'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.24.13.linux-armv6l.tar.gz'; \
			sha256='a26b1e54c0fe7b0babc79716a89b830f1cde54f6c6f914a9995d3f0d0bdd0242'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.24.13.linux-arm64.tar.gz'; \
			sha256='74d97be1cc3a474129590c67ebf748a96e72d9f3a2b6fef3ed3275de591d49b3'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.24.13.linux-386.tar.gz'; \
			sha256='a55cb4587b1face90dc9334d8ad44ccd41fade77dcff645a74927eb0adc52272'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.24.13.linux-ppc64le.tar.gz'; \
			sha256='5f0dfab58ce15a84d824363c041246c76847a69d14f9ffac16bd5342299ecc14'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.24.13.linux-riscv64.tar.gz'; \
			sha256='9a8166261489d3f38c7a568785b7012c123e3561779d282d568a72d58506754f'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.24.13.linux-s390x.tar.gz'; \
			sha256='a3e3e2012f9b4d392fab85fd4596bbd798ea8e0ceba259f47023b8cb5ebfffc1'; \
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
	keyserverOptions=$( [ -n "${HTTP_PROXY+set}" ] && echo "--keyserver-options http-proxy=${HTTP_PROXY}" || echo "" ); \
	gpg --batch --keyserver keyserver.ubuntu.com ${keyserverOptions} --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC  EC91 7721 F63B D38B 4796'; \
# let's also fetch the specific subkey of that key explicitly that we expect "go.tgz.asc" to be signed by, just to make sure we definitely have it
	gpg --batch --keyserver keyserver.ubuntu.com ${keyserverOptions} --recv-keys '2F52 8D36 D67B 69ED F998  D857 78BD 6547 3CB3 BD13'; \
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

ENV GOLANG_VERSION 1.24.13

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# (see notes above about "COPY --link")
COPY --from=build --link /target/ /
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
