#!/bin/bash
set -e

declare -A aliases
aliases=(
	[1.3]='1 latest'
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
url='git://github.com/docker-library/golang'

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'

for version in "${versions[@]}"; do
	commit="$(git log -1 --format='format:%H' "$version")"
	fullVersion="$(grep -m1 'ENV GOLANG_VERSION ' "$version/Dockerfile" | cut -d' ' -f3)"
	versionAliases=( $fullVersion $version ${aliases[$version]} )
	
	echo
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit} $version"
	done
	
	for variant in onbuild cross; do
		echo
		for va in "${versionAliases[@]}"; do
			if [ "$va" = 'latest' ]; then
				va="$variant"
			else
				va="$va-$variant"
			fi
			echo "$va: ${url}@${commit} $version/$variant"
		done
	done
done
