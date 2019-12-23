#!/usr/bin/env bash
set -Eeuo pipefail

declare -A aliases=(
	[1.13]='1 latest'
	[1.14-rc]='rc'
)

defaultDebianSuite='buster'
declare -A debianSuite=(
	#[1.13-rc]='buster'
)
defaultAlpineVersion='3.11'
declare -A alpineVersion=(
	#[1.9]='3.7'
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
		files="$(
			git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						if ($i ~ /^--from=/) {
							next
						}
						print $i
					}
				}
			'
		)"
		fileCommit Dockerfile $files
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
		buster stretch alpine{3.11,3.10} \
		windows/windowsservercore-{ltsc2016,1809} \
		windows/nanoserver-1809 \
	; do
		dir="$version/$v"

		[ -f "$dir/Dockerfile" ] || continue

		variant="$(basename "$v")"
		versionSuite="${debianSuite[$version]:-$defaultDebianSuite}"

		commit="$(dirCommit "$dir")"
		fullVersion="$(git show "$commit":"$dir/Dockerfile" | awk '$1 == "ENV" && $2 == "GOLANG_VERSION" { print $3; exit }')"

		[[ "$fullVersion" == *.*[^0-9]* ]] || fullVersion+='.0'

		if [ "$version" = "$fullVersion" ]; then
			baseAliases=( "${versionAliases[@]}" )
		else
			baseAliases=( $fullVersion "${versionAliases[@]}" )
		fi
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

		constraints=
		if [ "$variant" != "$v" ]; then
			constraints="$variant"
			if [[ "$variant" == nanoserver-* ]]; then
				# nanoserver variants "COPY --from=...:...-windowsservercore-... ..."
				constraints+=", windowsservercore-${variant#nanoserver-}"
			fi
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
		[ -z "$constraints" ] || echo "Constraints: $constraints"
	done
done
