#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )


travisEnv=
googleSource="$(curl -fsSL 'https://golang.org/dl/')"
for version in "${versions[@]}"; do
	# First check for full version from GitHub as a canonical source
	fullVersion="$(curl -fsSL "https://raw.githubusercontent.com/golang/go/release-branch.go$version/VERSION" 2>/dev/null || true)"
	if [ -z "$fullVersion" ]; then
		echo >&2 "warning: cannot find version from GitHub for $version, scraping golang download page"
		fullVersion="$(echo $googleSource | grep -Po '">go'"$version"'.*?\.src\.tar\.gz</a>' | sed -r 's!.*go([^"/<]+)\.src\.tar\.gz.*!\1!' | sort -V | tail -1)"
	fi
	if [ -z "$fullVersion" ]; then
		echo >&2 "warning: cannot find full version for $version"
		continue
	fi
	fullVersion="${fullVersion#go}" # strip "go" off "go1.4.2"
	versionTag="$fullVersion"

	# Try and fetch the checksum from the golang source page
	linuxSha256="$(echo $googleSource | grep -Po '">go'"$fullVersion"'\.linux-amd64\.tar\.gz</a>.*?>[a-f0-9]{40,64}<' | sed -r 's!.*>([a-f0-9]{64})<.*!\1!; s!.*[<>]+.*!!' | tail -1)"
	if [ -z "$linuxSha256" ]; then
		echo >&2 "warning: cannot find sha256 for $fullVersion"
		continue
	fi

	srcSha256="$(echo $googleSource | grep -Po '">go'"$fullVersion"'\.src\.tar\.gz</a>.*?>[a-f0-9]{40,64}<' | sed -r 's!.*>([a-f0-9]{64})<.*!\1!; s!.*[<>]+.*!!' | tail -1)"

	[[ "$versionTag" == *.*[^0-9]* ]] || versionTag+='.0'
	(
		set -x
		sed -ri '
			s/^(ENV GOLANG_VERSION) .*/\1 '"$fullVersion"'/;
			s/^(ENV GOLANG_DOWNLOAD_SHA256) .*/\1 '"$linuxSha256"'/;
			s/^(ENV GOLANG_SRC_SHA256) .*/\1 '"$srcSha256"'/;
			s/^(FROM golang):.*/\1:'"$version"'/;
		' "$version/Dockerfile" "$version/"*"/Dockerfile"
		cp go-wrapper "$version/"
	)
	for variant in alpine wheezy; do
		if [ -d "$version/$variant" ]; then
			if [ "$variant" != 'alpine' ]; then
				(
					set -x
					sed 's/^FROM .*/FROM buildpack-deps:'"$variant"'-scm/' "$version/Dockerfile" > "$version/$variant/Dockerfile"
				)
			fi
			cp "$version/go-wrapper" "$version/$variant/"
			travisEnv='\n  - VERSION='"$version VARIANT=$variant$travisEnv"
		fi
	done
	travisEnv='\n  - VERSION='"$version VARIANT=$travisEnv"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
