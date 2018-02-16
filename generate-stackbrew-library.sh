#!/usr/bin/env bash
set -Eeuo pipefail

declare -A aliases=(
	[1.10]='1 latest'
	[1.11-rc]='rc'
)

defaultDebianSuite='stretch'
declare -A debianSuite=(
)
defaultAlpineVersion='3.7'
declare -A alpineVersion=(
	[1.9]='3.6'
)

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

source '.architectures-lib'

versions=( */ )
versions=( "${versions[@]%/}" )

# sort version numbers with highest first
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -rV) ); unset IFS

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit \
			Dockerfile \
			$(git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						print $i
					}
				}
			')
	)
}

cat <<-EOH
# this file is generated via https://github.com/docker-library/golang/blob/$(fileCommit "$self")/$self

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit),
             Johan Euphrosine <proppy@google.com> (@proppy)
GitRepo: https://github.com/docker-library/golang.git
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

for version in "${versions[@]}"; do
	rcVersion="${version%-rc}"

	versionAliases=(
		$version
		${aliases[$version]:-}
	)

	for v in \
		stretch alpine3.{7,6} \
		windows/windowsservercore-{ltsc2016,1709} \
		windows/nanoserver-{sac2016,1709} \
	; do
		dir="$version/$v"

		[ -f "$dir/Dockerfile" ] || continue

		variant="$(basename "$v")"
		versionSuite="${debianSuite[$version]:-$defaultDebianSuite}"

		commit="$(dirCommit "$dir")"
		fullVersion="$(git show "$commit":"$dir/Dockerfile" | awk '$1 == "ENV" && $2 == "GOLANG_VERSION" { print $3; exit }')"

		[[ "$fullVersion" == *.*[^0-9]* ]] || fullVersion+='.0'

		baseAliases=( $fullVersion "${versionAliases[@]}" )
		variantAliases=( "${baseAliases[@]/%/-$variant}" )
		variantAliases=( "${variantAliases[@]//latest-/}" )

		if [ "${variant#alpine}" = "${alpineVersion[$version]:-$defaultAlpineVersion}" ]; then
			variantAliases+=( "${baseAliases[@]/%/-alpine}" )
			variantAliases=( "${variantAliases[@]//latest-/}" )
		fi

		case "$v" in
			alpine*)   variantArches="$(parentArches "$version" "$v")" ;;
			windows/*) variantArches='windows-amd64' ;;
			*)         variantArches="$(variantArches "$version" "$v")" ;;
		esac

		sharedTags=()
		for windowsShared in windowsservercore nanoserver; do
			if [[ "$variant" == "$windowsShared"* ]]; then
				sharedTags=( "${baseAliases[@]/%/-$windowsShared}" )
				sharedTags=( "${sharedTags[@]//latest-/}" )
				break
			fi
		done
		if [ "$variant" = "$versionSuite" ] || [[ "$variant" == 'windowsservercore'* ]]; then
			sharedTags+=( "${baseAliases[@]}" )
		fi

		echo
		echo "Tags: $(join ', ' "${variantAliases[@]}")"
		if [ "${#sharedTags[@]}" -gt 0 ]; then
			echo "SharedTags: $(join ', ' "${sharedTags[@]}")"
		fi
		cat <<-EOE
			Architectures: $(join ', ' $variantArches)
			GitCommit: $commit
			Directory: $dir
		EOE
		[ "$variant" = "$v" ] || echo "Constraints: $variant"
	done
done
