#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:bullseye-scm AS build

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.22.0

RUN set -eux; \
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	url=; \
	case "$arch" in \
		'amd64') \
			url='https://dl.google.com/go/go1.22.0.linux-amd64.tar.gz'; \
			sha256='f6c8a87aa03b92c4b0bf3d558e28ea03006eb29db78917daec5cfb6ec1046265'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.22.0.linux-armv6l.tar.gz'; \
			sha256='0525f92f79df7ed5877147bce7b955f159f3962711b69faac66bc7121d36dcc4'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go1.22.0.linux-arm64.tar.gz'; \
			sha256='6a63fef0e050146f275bf02a0896badfe77c11b6f05499bb647e7bd613a45a10'; \
			;; \
		'i386') \
			url='https://dl.google.com/go/go1.22.0.linux-386.tar.gz'; \
			sha256='1e209c4abde069067ac9afb341c8003db6a210f8173c77777f02d3a524313da3'; \
			;; \
		'mips64el') \
			url='https://dl.google.com/go/go1.22.0.linux-mips64le.tar.gz'; \
			sha256='c162a1a516b8bc8839fc0c0283ad90f6b511e5aca3da4939ed4800f124b9e72c'; \
			;; \
		'ppc64el') \
			url='https://dl.google.com/go/go1.22.0.linux-ppc64le.tar.gz'; \
			sha256='0e57f421df9449066f00155ce98a5be93744b3d81b00ee4c2c9b511be2a31d93'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.22.0.linux-riscv64.tar.gz'; \
			sha256='afe9cedcdbd6fdff27c57efd30aa5ce0f666f471fed5fa96cd4fb38d6b577086'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.22.0.linux-s390x.tar.gz'; \
			sha256='2e546a3583ba7bd3988f8f476245698f6a93dfa9fe206a8ca8f85c1ceecb2446'; \
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

ENV GOLANG_VERSION 1.22.0

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
COPY --from=build --link /usr/local/go/ /usr/local/go/
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
