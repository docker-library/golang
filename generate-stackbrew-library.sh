#!/usr/bin/env bash
set -Eeuo pipefail

declare -A aliases=(
	[1.22]='1 latest'
)

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

# sort version numbers with highest first
IFS=$'\n'; set -- $(sort -rV <<<"$*"); unset IFS

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

getArches() {
	local repo="$1"; shift
	local officialImagesUrl='https://github.com/docker-library/official-images/raw/master/library/'

	eval "declare -g -A parentRepoToArches=( $(
		find -name 'Dockerfile' -exec awk '
				toupper($1) == "FROM" && $2 !~ /^('"$repo"'|scratch|.*\/.*)(:|$)/ {
					print "'"$officialImagesUrl"'" $2
				}
			' '{}' + \
			| sort -u \
			| xargs bashbrew cat --format '[{{ .RepoName }}:{{ .TagName }}]="{{ join " " .TagEntry.Architectures }}"'
	) )"
}
getArches 'golang'

cat <<-EOH
# this file is generated via https://github.com/docker-library/golang/blob/$(fileCommit "$self")/$self

Maintainers: Tianon Gravi <admwiggin@gmail.com> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit),
             Johan Euphrosine <proppy@google.com> (@proppy)
GitRepo: https://github.com/docker-library/golang.git
Builder: buildkit
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

for version; do
	export version
	variants="$(jq -r '.[env.version].variants | map(@sh) | join(" ")' versions.json)"
	eval "variants=( $variants )"

	versionAliases=(
		$version
		${aliases[$version]:-}
	)

	defaultDebianVariant="$(jq -r '
		.[env.version].variants
		| map(select(
			startswith("alpine")
			or startswith("slim-")
			or startswith("windows/")
			| not
		))
		| .[0]
	' versions.json)"
	defaultAlpineVariant="$(jq -r '
		.[env.version].variants
		| map(select(
			startswith("alpine")
		))
		| .[0]
	' versions.json)"

	for v in "${variants[@]}"; do
		dir="$version/$v"
		[ -f "$dir/Dockerfile" ] || continue

		variant="$(basename "$v")"

		fullVersion="$(jq -r '.[env.version].version' versions.json)"

		[[ "$fullVersion" == *.*[^0-9]* ]] || fullVersion+='.0'

		if [ "$version" = "$fullVersion" ]; then
			baseAliases=( "${versionAliases[@]}" )
		else
			baseAliases=( $fullVersion "${versionAliases[@]}" )
		fi
		variantAliases=( "${baseAliases[@]/%/-$variant}" )
		variantAliases=( "${variantAliases[@]//latest-/}" )

		if [ "$variant" = "$defaultAlpineVariant" ]; then
			variantAliases+=( "${baseAliases[@]/%/-alpine}" )
			variantAliases=( "${variantAliases[@]//latest-/}" )
		fi

		case "$v" in
			windows/*)
				variantArches='windows-amd64'
				;;

			*)
				variantParent="$(awk 'toupper($1) == "FROM" { print $2 }' "$dir/Dockerfile" | sort -u)" # TODO this needs to handle multi-parents (we get lucky that they're the same)
				variantArches="${parentRepoToArches[$variantParent]}"
				;;
		esac

		# cross-reference with supported architectures
		for arch in $variantArches; do
			if ! jq -e --arg arch "$arch" '.[env.version].arches[$arch].supported' versions.json &> /dev/null; then
				variantArches="$(sed <<<" $variantArches " -e "s/ $arch / /g")"
			fi
		done
		# TODO rewrite this whole loop into a single jq expression :)
		variantArches="${variantArches% }"
		variantArches="${variantArches# }"
		if [ -z "$variantArches" ]; then
			echo >&2 "error: '$dir' has no supported architectures!"
			exit 1
		fi

		sharedTags=()
		for windowsShared in windowsservercore nanoserver; do
			if [[ "$variant" == "$windowsShared"* ]]; then
				sharedTags=( "${baseAliases[@]/%/-$windowsShared}" )
				sharedTags=( "${sharedTags[@]//latest-/}" )
				break
			fi
		done
		if [ "$variant" = "$defaultDebianVariant" ] || [[ "$variant" == 'windowsservercore'* ]]; then
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

		commit="$(dirCommit "$dir")"

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
		if [ -n "$constraints" ]; then
			echo 'Builder: classic'
			echo "Constraints: $constraints"
		fi
	done
done
