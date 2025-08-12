#!/usr/bin/env bash
set -Eeuo pipefail

# see https://golang.org/dl/
potentiallySupportedArches=(
	amd64
	arm32v5
	arm32v6
	arm32v7
	arm64v8
	i386
	mips64le
	ppc64le
	riscv64
	s390x
	windows-amd64

	# special case (fallback)
	src
)
potentiallySupportedArches="$(jq -sRc <<<"${potentiallySupportedArches[*]}" 'rtrimstr("\n") | split(" ")')"

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
	json='{}'
else
	json="$(< versions.json)"
fi
versions=( "${versions[@]%/}" )

# https://pkg.go.dev/golang.org/x/website/internal/dl
# https://github.com/golang/go/issues/23746
# https://github.com/golang/go/issues/34864
# https://github.com/golang/website/blob/41e922072f17ab2826d9479338314c025602a3a1/internal/dl/server.go#L174-L182 ... (the only way to get "unstable" releases is via "all", so we get to sort through "archive" releases too)
goVersions="$(
	wget -qO- 'https://golang.org/dl/?mode=json&include=all' | jq -c '
		[
			.[]
			| ( .version | ltrimstr("go") ) as $version
			| ( $version | sub("^(?<m>[0-9]+[.][0-9]+).*$"; "\(.m)") ) as $major
			| {
				version: $version,
				major: ( $major + if .stable then "" else "-rc" end ),
				arches: (
					[
						.files[]
						| select(.kind == "archive" or .kind == "source")
						| (
							if .kind == "source" then
								"src"
							else
								if .os != "linux" then
									.os + "-"
								else "" end
								+ (
									.arch
									| sub("^386$"; "i386")
									| sub("^arm64$"; "arm64v8")
									| sub("^arm-?v?(?<v>[0-9]+)l?$"; "arm32v\(.v)")
								)
							end
						) as $bashbrewArch
						| {
							( $bashbrewArch ): (
								{
									url: ("https://dl.google.com/go/" + .filename),
									sha256: .sha256,
									env: { GOOS: .os, GOARCH: .arch },
								}
							),
						}
					]
					| add

					# upstream (still as of 2023-12-19) only publishes "armv6" binaries, which are appropriate for v7 as well
					| if (has("arm32v7") | not) and has("arm32v6") then
						.["arm32v7"] = .["arm32v6"]
					else . end
				)
			}
		]
	'
)"

for version in "${versions[@]}"; do
	export version

	case "$version" in
		tip)
			# clamp so we don't update too frequently (https://github.com/docker-library/golang/issues/464#issuecomment-1587758290, https://github.com/docker-library/faq#can-i-use-a-bot-to-make-my-image-update-prs)
			# https://github.com/golang/go
			# https://go.googlesource.com/go
			snapshotDate="$(date --utc --date 'last sunday 23:59:59 UTC + 1 second' '+%s')"
			snapshotDateStr="$(date --utc --date "@$snapshotDate" '+%Y-%m-%d @ %H:%M:%S')"
			commit='HEAD' # this is also our iteration variable, so if we don't find a suitable commit each time through this loop, we'll use the last commit of the previous list to get a list of new (older) commits until we find one suitably old enough
			fullVersion=
			date=
			while [ -z "$fullVersion" ]; do
				commits="$(
					# wget -qO- 'https://go.googlesource.com/go/+log/refs/heads/master?format=JSON' # the first line of this is ")]}'" for avoiding javscript injection vulnerabilities, which is annoying, and the dates are *super* cursed ("Mon Dec 04 10:00:41 2023 -0800") -- even date(1) doesn't want to parse them ("date: invalid date ‘Mon Dec 04 10:00:41 2023 -0800’")
					# ... so we use GitHub's "atom feeds" endpoint instead, which if you ask for JSON, gives back JSON 😄
					wget -qO- --header 'Accept: application/json' "https://github.com/golang/go/commits/$commit.atom" \
						| jq -r '
							.payload.commitGroups[].commits[]
							| first([ .committedDate, .authoredDate ] | sort | reverse[]) as $date
							| "\(.oid) \($date)"
							| @sh
						'
				)"
				eval "commitDates=( $commits )"
				if [ "${#commitDates[@]}" -eq 0 ]; then
					echo >&2 "error: got no commits when listing history from $commit"
					exit 1
				fi
				for commitDate in "${commitDates[@]}"; do
					commit="${commitDate%%[[:space:]]*}"
					date="${commitDate#$commit[[:space:]]}"
					[ "$commit" != "$date" ] # sanity check
					date="$(date --utc --date "$date" '+%s')"
					if [ "$date" -le "$snapshotDate" ]; then
						fullVersion="$commit"
						break 2
					fi
				done
			done
			if [ -z "$fullVersion" ]; then
				echo >&2 "error: cannot find full version for $version (maybe too many commits since $snapshotDateStr?)"
				exit 1
			fi
			[ "$commit" = "$fullVersion" ]
			[ -n "$date" ]
			fullVersion="$(date --utc --date "@$date" '+%Y%m%d')"
			url="https://github.com/golang/go/archive/$commit.tar.gz"
			sha256= # TODO "$(wget -qO- "$url" | sha256sum | cut -d' ' -f1)" # 😭 (this is not fast)
			goJson="$(
				export fullVersion commit dateStr date url sha256
				jq -nc '
					{
						version: "tip-\(env.fullVersion)",
						commit: {
							version: env.commit,
						},
						arches: {
							src: {
								url: env.url,
								#sha256: env.sha256,
							},
						},
					}
				'
			)"
			;;

		*)
			if \
				! goJson="$(jq <<<"$goVersions" -ce '
					[ .[] | select(.major == env.version) ] | sort_by(
						.version
						| split(".")
						| map(
							if test("^[0-9]+$") then
								tonumber
							else . end
						)
					)[-1]
				')" \
				|| ! fullVersion="$(jq <<<"$goJson" -r '.version')" \
				|| [ -z "$fullVersion" ] \
			; then
				echo >&2 "warning: cannot find full version for $version"
				continue
			fi
			;;
	esac

	echo "$version: $fullVersion"

	doc="$(jq <<<"$goJson" -c --argjson potentiallySupportedArches "$potentiallySupportedArches" '
	{
		version: .version,
		commit: .commit,
		date: .date,
		arches: (
			.arches
			| . += (
				( $potentiallySupportedArches - keys ) # "missing" arches that we ought to include in our list
				| map(
					{
						(.): {
							env: (
								# hacky, but probably close enough (cleaned up in the next block)
								capture("^((?<GOOS>[^-]+)-)?(?<GOARCH>.+)$")
								| .GOOS //= "linux"
							)
						},
					}
				)
				| add
			)
			| with_entries(
				.key as $bashbrewArch
				| .value.supported = (
					.key != "src"
					and (
						# https://github.com/docker-library/golang/pull/500#issuecomment-1863578601 - as of Go 1.21+, we no longer build from source (except for tip builds)
						.value.url
						or env.version == "tip"
					)
					and ($potentiallySupportedArches | index($bashbrewArch))
				)
				| .value.env +=
						if $bashbrewArch == "i386" then
							# i386 in Debian is non-SSE2, Alpine appears to be similar (but interesting, not FreeBSD?)
							{ GOARCH: "386", GO386: "softfloat" }
						elif $bashbrewArch == "amd64" then
							# https://go.dev/doc/go1.18#amd64
							{ GOAMD64: "v1" }
						# TODO ^^ figure out what to do with GOAMD64 / GO386 if/when the OS baselines change and these choices needs to be per-variant /o\ (probably move it to the template instead, in fact, since that is where we can most easily toggle based on variant)
						elif $bashbrewArch == "riscv64" then
							# https://go.dev/doc/go1.23#riscv
							{ GORISCV64: "rva20u64" }
						elif $bashbrewArch | startswith("arm64v") then
							{
								GOARCH: "arm64",
								# https://go.dev/doc/go1.23#arm64
								GOARM64: ($bashbrewArch | ltrimstr("arm64") | if index(".") then . else . + ".0" end),
							}
						elif $bashbrewArch | startswith("arm32v") then
							{ GOARCH: "arm", GOARM: ($bashbrewArch | ltrimstr("arm32v")) }
						else {} end
				| if $bashbrewArch == "src" then del(.value.env) else . end
			)
		),
		variants: [
			"trixie",
			"bookworm",
			(
				"3.22",
				"3.21",
				empty
			| "alpine" + .),
			if .arches | has("windows-amd64") and .["windows-amd64"].url then # TODO consider windows + tip
				(
					"ltsc2025",
					"ltsc2022",
					empty
				| "windows/windowsservercore-" + .),
				(
					"ltsc2025",
					"ltsc2022",
					empty
				| "windows/nanoserver-" + .)
			else empty end
		],
	}
	# if "date" or "commit" are null, exclude them
	| with_entries(select(.value))
	')"

	json="$(jq <<<"$json" -c --argjson doc "$doc" '.[env.version] = $doc')"
done

jq <<<"$json" '
	to_entries
	| sort_by(
		.key
		| [
			if . == "tip" then 0 else 1 end, # make sure tip is first so it ends up last when we reverse
			(split("[.-]"; "") | map(tonumber? // .))
		]
	)
	| reverse
	| from_entries
	| .[].arches |= (
		to_entries
		| sort_by(.key)
		| from_entries
	)
' > versions.json
