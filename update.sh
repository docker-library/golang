#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	fullVersion="$(curl -sSL 'https://golang.org/dl' | grep '">go'"$version"'.*\.src.tar.gz<' | sed -r 's!.*go([^"/<]+)\.src\.tar\.gz.*!\1!' | sort -V | tail -1)"
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
				sed -i 's/^FROM .*/FROM debian:'"$variant"'/' "$version/$variant/Dockerfile"
			)
		fi
	done
done
