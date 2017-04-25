#!/bin/bash
set -Eeuo pipefail

# a mapping of "dpkg --print-architecture" to Go release arch
# see https://golang.org/dl/
declare -A dpkgArches=(
	[amd64]='amd64'
	[armhf]='armv6l'
	[i386]='386'
	[ppc64el]='ppc64le'
	[s390x]='s390x'
)

defaultDebianSuite='stretch'
declare -A debianSuite=(
	[1.8]='jessie'
	[1.7]='jessie'
)
defaultAlpineVersion='3.5'
declare -A alpineVersion=(
	[1.7]='3.4'
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

# see http://stackoverflow.com/a/2705678/433558
sed_escape_lhs() {
	echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
}
sed_escape_rhs() {
	echo "$@" | sed -e 's/[\/&]/\\&/g' | sed -e ':a;N;$!ba;s/\n/\\n/g'
}

googleSource="$(curl -fsSL 'https://golang.org/dl/')"
scrape_sha256() {
	local filename="$1"
	echo $googleSource | grep -Po '">'"$(sed_escape_lhs "$filename")"'</a>.*?>[a-f0-9]{40,64}<' | sed -r 's!.*>([a-f0-9]{64})<.*!\1!; s!.*[<>]+.*!!' | tail -1
}

travisEnv=
appveyorEnv=
for version in "${versions[@]}"; do
	rcVersion="${version%-rc}"
	rcGrepV='-v'
	if [ "$rcVersion" != "$version" ]; then
		rcGrepV=
	fi
	rcGrepV+=' -E'
	rcGrepExpr='rc'

	# First check for full version from GitHub as a canonical source
	fullVersion="$(curl -fsSL "https://raw.githubusercontent.com/golang/go/release-branch.go$rcVersion/VERSION" 2>/dev/null | grep $rcGrepV -- "$rcGrepExpr" || true)"
	if [ -z "$fullVersion" ]; then
		echo >&2 "warning: cannot find version from GitHub for $version, scraping golang download page"
		fullVersion="$(echo $googleSource | grep -Po '">go'"$rcVersion"'.*?\.src\.tar\.gz</a>' | sed -r 's!.*go([^"/<]+)\.src\.tar\.gz.*!\1!' | grep $rcGrepV -- "$rcGrepExpr" | sort -V | tail -1)"
	fi
	if [ -z "$fullVersion" ]; then
		echo >&2 "warning: cannot find full version for $version"
		continue
	fi
	fullVersion="${fullVersion#go}" # strip "go" off "go1.4.2"

	srcSha256="$(scrape_sha256 "go${fullVersion}.src.tar.gz")"
	linuxArchCase='dpkgArch="$(dpkg --print-architecture)"; '$'\\\n'
	linuxArchCase+=$'\t''case "${dpkgArch##*-}" in '$'\\\n'
	for dpkgArch in "${!dpkgArches[@]}"; do
		goArch="${dpkgArches[$dpkgArch]}"
		sha256="$(scrape_sha256 "go${fullVersion}.linux-${goArch}.tar.gz")"
		if [ -z "$sha256" ]; then
			echo >&2 "warning: cannot find sha256 for $fullVersion on arch $goArch"
			continue 2
		fi
		linuxArchCase+=$'\t\t'"$dpkgArch) goRelArch='linux-$goArch'; goRelSha256='$sha256' ;; "$'\\\n'
	done
	linuxArchCase+=$'\t\t'"*) goRelArch='src'; goRelSha256='$srcSha256'; "$'\\\n'
	linuxArchCase+=$'\t\t\t''echo >&2; echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; echo >&2 ;; '$'\\\n'
	linuxArchCase+=$'\t''esac'
	windowsSha256="$(scrape_sha256 "go${fullVersion}.windows-amd64.zip")"

	for variant in alpine3.5 alpine; do
		if [ -d "$version/$variant" ]; then
			ver="${variant#alpine}"
			ver="${ver:-${alpineVersion[$version]:-$defaultAlpineVersion}}"
			sed -r \
				-e 's!%%VERSION%%!'"$fullVersion"'!g' \
				-e 's!%%ALPINE-VERSION%%!'"$ver"'!g' \
				-e 's!%%SRC-SHA256%%!'"$srcSha256"'!g' \
				Dockerfile-alpine.template > "$version/$variant/Dockerfile"
			cp go-wrapper "$version/$variant/"
			travisEnv='\n  - VERSION='"$version VARIANT=$variant$travisEnv"
		fi
	done
	for variant in stretch wheezy ''; do
		if [ -d "$version/$variant" ]; then
			sed -r \
				-e 's!%%VERSION%%!'"$fullVersion"'!g' \
				-e 's!%%DEBIAN-SUITE%%!'"${variant:-${debianSuite[$version]:-$defaultDebianSuite}}"'!g' \
				-e 's!%%ARCH-CASE%%!'"$(sed_escape_rhs "$linuxArchCase")"'!g' \
				Dockerfile-debian.template > "$version/$variant/Dockerfile"
			cp go-wrapper "$version/$variant/"
			travisEnv='\n  - VERSION='"$version VARIANT=$variant$travisEnv"
		fi
	done
	for winVariant in windowsservercore nanoserver; do
		if [ -d "$version/windows/$winVariant" ]; then
			sed -r \
				-e 's!%%VERSION%%!'"$fullVersion"'!g' \
				-e 's!%%WIN-SHA256%%!'"$windowsSha256"'!g' \
				"Dockerfile-windows-$winVariant.template" > "$version/windows/$winVariant/Dockerfile"
			appveyorEnv='\n    - version: '"$version"'\n      variant: '"$winVariant$appveyorEnv"
		fi
	done

	echo "$version: $fullVersion ($srcSha256)"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml

appveyor="$(awk -v 'RS=\n\n' '$1 == "environment:" { $0 = "environment:\n  matrix:'"$appveyorEnv"'" } { printf "%s%s", $0, RS }' .appveyor.yml)"
echo "$appveyor" > .appveyor.yml
