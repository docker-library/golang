#!/usr/bin/env bash
set -Eeuo pipefail

# see https://golang.org/dl/
declare -A golangArches=(
	['amd64']='linux-amd64'
	['arm32v7']='linux-armv6l'
	['arm64v8']='linux-arm64'
	['i386']='linux-386'
	['ppc64le']='linux-ppc64le'
	['s390x']='linux-s390x'
	['windows-amd64']='windows-amd64'

	# special case (fallback)
	['src']='src'
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
	json='{}'
else
	json="$(< versions.json)"
fi
versions=( "${versions[@]%/}" )

# https://github.com/golang/go/issues/13220
allGoVersions='{}'
apiBaseUrl='https://www.googleapis.com/storage/v1/b/golang/o?fields=nextPageToken,items%2Fname'
pageToken=
while [ "$pageToken" != 'null' ]; do
	page="$(curl -fsSL "$apiBaseUrl&pageToken=$pageToken")"
	# now that we have this page's data, get ready for the next request
	pageToken="$(jq <<<"$page" -r '.nextPageToken')"

	# for each API page, collect the "version => arches" pairs we find
	goVersions="$(
		jq <<<"$page" -r '
			[
				.items as $items
				| $items[].name
				| match("^go([0-9].*)[.](src|(linux|windows)-[^.]+)[.](tar[.]gz|zip)$")
				| .captures[0].string as $version
				| .captures[1].string as $arch
				| { version: $version, arch: $arch }
			] | reduce .[] as $o (
				{};
				.[$o.version] += [ $o.arch ]
			)
		'
	)"

	# ... and aggregate them together into a single object of "version => arches" pairs
	allGoVersions="$(
		jq <<<"$allGoVersions"$'\n'"$goVersions" -cs '
			map(to_entries) | add
			| reduce .[] as $o (
				{};
				.[$o.key] = (
					$o.value + .[$o.key]
					| unique
				)
			)
		'
	)"
done

for version in "${versions[@]}"; do
	rcVersion="${version%-rc}"
	rcRegex='^[^a-z]*$'
	if [ "$rcVersion" != "$version" ]; then
		# beta, rc, etc
		rcRegex='[a-z]+[0-9]*$'
	fi

	export rcVersion rcRegex
	fullVersion="$(
		jq <<<"$allGoVersions" -r '
			. as $map
			| keys[] | select(
				startswith(env.rcVersion)
				and (
					ltrimstr(env.rcVersion)
					| test(env.rcRegex)
				)
				and ($map[.] | index("src"))
			)
		' | sort -rV | head -1
	)"
	if [ -z "$fullVersion" ]; then
		echo >&2 "warning: cannot find full version for $version"
		continue
	fi

	echo "$version: $fullVersion"

	export fullVersion
	doc="$(
		jq -nc '{
			version: env.fullVersion,
			arches: {},
			variants: [],
		}'
	)"

	arches="$(jq <<<"$allGoVersions" -c '.[env.fullVersion]')"

	# loop over bashbrew arches, get sha256 for each one supported
	for bashbrewArch in "${!golangArches[@]}"; do
		arch="${golangArches[$bashbrewArch]}"
		export arch
		if jq <<<"$arches" -e 'index(env.arch) != null' > /dev/null; then
			file="go${fullVersion}.$arch.$([[ "$arch" == windows-* ]] && echo 'zip' || echo 'tar.gz')"
			url="https://storage.googleapis.com/golang/$file"
			# https://github.com/golang/build/commit/24f7399f96feb8dd2fc54f064e47a886c2f8bb4a
			if sha256="$(curl -fsSL "$url.sha256")"; then
				export bashbrewArch arch url sha256
				doc="$(
					jq <<<"$doc" -c '.arches[env.bashbrewArch] = {
						arch: env.arch,
						url: env.url,
						sha256: env.sha256,
					}'
				)"
			fi
		fi
	done

	# order here controls the order of the library/ file
	for variant in \
		buster \
		stretch \
		\
		alpine3.12 \
		alpine3.11 \
		\
		windows/windowsservercore-{1809,ltsc2016} \
		windows/nanoserver-1809 \
	; do
		base="${variant%%/*}" # "buster", "windows", etc.
		[ -d "$version/$base" ] || continue
		if [ "$base" = 'windows' ] && ! jq <<<"$arches" -e 'index("windows-amd64")' > /dev/null; then
			continue
		fi
		export variant
		doc="$(jq <<<"$doc" -c '.variants += [ env.variant ]')"
	done

	export version
	json="$(jq <<<"$json" -c --argjson doc "$doc" '.[env.version] = $doc')"
done

jq <<<"$json" -S . > versions.json
