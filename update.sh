#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	fullVersion="$(curl -fsSL "https://raw.githubusercontent.com/golang/go/release-branch.go$version/VERSION" 2>/dev/null || true)"
	if [ -z "$fullVersion" ]; then
		fullVersion="$(curl -fsSL 'https://golang.org/dl' | grep '">go'"$version"'.*\.src\.tar\.gz<' | sed -r 's!.*go([^"/<]+)\.src\.tar\.gz.*!\1!' | sort -V | tail -1)"
	fi
	if [ -z "$fullVersion" ]; then
		echo >&2 "warning: cannot find full version for $version"
		continue
	fi
	fullVersion="${fullVersion#go}" # strip "go" off "go1.4.2"
	versionTag="$fullVersion"
	[[ "$versionTag" == *.*[^0-9]* ]] || versionTag+='.0'
	(
		set -x
		sed -ri 's/^(ENV GOLANG_VERSION) .*/\1 '"$fullVersion"'/' "$version/Dockerfile"
		sed -ri 's/^(FROM golang):.*/\1:'"$versionTag"'/' "$version/"*"/Dockerfile"
		cp go-wrapper "$version/"
	)
	for variant in wheezy; do
		if [ -d "$version/$variant" ]; then
			(
				set -x
				cp "$version/Dockerfile" "$version/go-wrapper" "$version/$variant/"
				sed -i 's/^FROM .*/FROM buildpack-deps:'"$variant"'-scm/' "$version/$variant/Dockerfile"
			)
		fi
	done
done
