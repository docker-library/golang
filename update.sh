#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	#fullVersion="$(curl -sSL 'https://golang.org/dl' | grep '">go'"$version"'.*\.src.tar.gz<' | sed -r 's!.*go([^"/<]+)\.src\.tar\.gz.*!\1!' | sort -V | tail -1)"
	fullVersion="$version"
	(
		set -x
		sed -ri 's/^(ENV GOLANG_VERSION) .*/\1 '"$fullVersion"'/' "$version/Dockerfile"
		sed -ri 's/^(FROM golang):.*/\1:'"$fullVersion"'/' "$version/"*"/Dockerfile"
		cp go-wrapper "$version/"
	)
done
