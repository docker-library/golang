#!/usr/bin/env bash
set -Eeuo pipefail

image="$1"

args=(
	# respond better to SIGINT/SIGTERM
	--init --interactive

	# Go has some tests that are very picky about DNS resolution
	--dns 8.8.8.8
	--dns 8.8.4.4
)

cmd=(
	# the "dist" tool doesn't query Go for GOROOT and expects it to be set explicitly
	sh -xec 'GOROOT="$(go env GOROOT)" && export GOROOT && exec "$@"' --

	# ideally this would just be "go tool dist test" but it isn't built by default (because most users don't need it)
	go run cmd/dist test
)

case "$image" in
	*alpine*)
		# Alpine needs a few extra dependencies installed for the tests to run/pass
		# gcc/libc-dev: cgo-related tests
		# iproute2-minimal: BusyBox's "ip" isn't enough for tests that need to shell out to "ip" for various env setup
		cmd=( sh -xec 'apk add --no-cache gcc libc-dev iproute2-minimal && exec "$@"' -- "${cmd[@]}" )
		# for some reason, running the tests on Alpine needs NET_ADMIN (but not on Debian 🤔)
		args+=( --cap-add NET_ADMIN )
		;;

	*windows* | *nanoserver*)
		echo >&2 "note: tests do not run successfully in a Windows container yet (https://github.com/docker-library/golang/issues/552#issuecomment-2658011431)"
		exit 0
		;;
esac

if [ -t 0 ] && [ -t 1 ]; then
	# let Ctrl+C DTRT if we're at a TTY
	args+=( --tty )
fi

docker run --rm "${args[@]}" "$image" "${cmd[@]}"
