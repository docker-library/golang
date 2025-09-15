#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.22 AS build

ENV PATH /usr/local/go/bin:$PATH

COPY --from=golang:alpine3.22 /usr/local/go /usr/local/goroot-bootstrap

# tip-20250912: https://github.com/golang/go/tree/ac803b5949f6dbc5bfa559afe506d35f9e1b3195
ARG GOLANG_COMMIT='ac803b5949f6dbc5bfa559afe506d35f9e1b3195'
ENV GOLANG_COMMIT $GOLANG_COMMIT

RUN set -eux; \
	now="$(date '+%s')"; \
	apk add --no-cache --virtual .fetch-deps \
		bash \
		git \
	; \
	arch="$(apk --print-arch)"; \
	case "$arch" in \
		'x86_64') \
			export GOAMD64='v1' GOARCH='amd64' GOOS='linux'; \
			;; \
		'armhf') \
			export GOARCH='arm' GOARM='6' GOOS='linux'; \
			;; \
		'armv7') \
			export GOARCH='arm' GOARM='7' GOOS='linux'; \
			;; \
		'aarch64') \
			export GOARCH='arm64' GOARM64='v8.0' GOOS='linux'; \
			;; \
		'x86') \
			export GO386='softfloat' GOARCH='386' GOOS='linux'; \
			;; \
		'ppc64le') \
			export GOARCH='ppc64le' GOOS='linux'; \
			;; \
		'riscv64') \
			export GOARCH='riscv64' GOOS='linux' GORISCV64='rva20u64'; \
			;; \
		's390x') \
			export GOARCH='s390x' GOOS='linux'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	\
# before we get too far, let's validate that our "bootstrap" Go works
	export GOROOT_BOOTSTRAP=/usr/local/goroot-bootstrap; \
	"$GOROOT_BOOTSTRAP/bin/go" version; \
	\
	git init --quiet /usr/local/go; \
	git -C /usr/local/go fetch --depth 1 https://github.com/golang/go.git "$GOLANG_COMMIT:"; \
	git -C /usr/local/go checkout --quiet FETCH_HEAD; \
	\
# save the Git timestamp so we can use it for reproducibility
	SOURCE_DATE_EPOCH="$(git -C /usr/local/go log -1 --format='format:%ct' HEAD)"; \
	export SOURCE_DATE_EPOCH; \
	touchy="$(date -d "@$SOURCE_DATE_EPOCH" '+%Y%m%d%H%M.%S')"; \
# for logging validation/edification
	date --date "@$SOURCE_DATE_EPOCH" --rfc-2822; \
# sanity check (detected value should be older than our wall clock)
	[ "$SOURCE_DATE_EPOCH" -lt "$now" ]; \
	\
	( \
		export \
			GOCACHE='/tmp/gocache' \
# set GOHOST* to make sure explicitly 32bit builds on 64bit infra work correctly
			GOHOSTOS="$GOOS" \
			GOHOSTARCH="$GOARCH" \
		; \
		\
		cd /usr/local/go/src; \
		./make.bash; \
		\
# remove a few intermediate / bootstrapping files the official binary release tarballs do not contain (and ".git" that is hard to make reproducible)
		rm -rf \
			/usr/local/go/.git* \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
			"$GOCACHE" \
		; \
		\
# clamp timestamps for reproducibility (allows "COPY --link" to be more clever/useful)
		touch -t "$touchy" /usr/local/.go-date-stamp; \
		find /usr/local/go -depth -newer /usr/local/.go-date-stamp -exec touch -ht "$touchy" '{}' +; \
		rm /usr/local/.go-date-stamp; \
	); \
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

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# (see notes above about "COPY --link")
COPY --from=build --link /target/ /
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH
