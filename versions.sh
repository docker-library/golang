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

	echo "$version: $fullVersion"

	doc="$(jq <<<"$goJson" -c --argjson potentiallySupportedArches "$potentiallySupportedArches" '{
		version: .version,
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
					# https://github.com/docker-library/golang/pull/500#issuecomment-1863578601 - as of Go 1.21+, we no longer build from source
					.value.url
					and ($potentiallySupportedArches | index($bashbrewArch))
				)
				| .value.env +=
						if $bashbrewArch == "i386" then
							# i386 in Debian is non-SSE2, Alpine appears to be similar (but interesting, not FreeBSD?)
							{ GOARCH: "386", GO386: "softfloat" }
						elif $bashbrewArch == "amd64" then
							# https://tip.golang.org/doc/go1.18#amd64
							{ GOAMD64: "v1" }
						# TODO ^^ figure out what to do with GOAMD64 / GO386 if/when the OS baselines change and these choices needs to be per-variant /o\ (probably move it to the template instead, in fact, since that is where we can most easily toggle based on variant)
						elif $bashbrewArch | startswith("arm64v") then
							{ GOARCH: "arm64" } # TODO do something with arm64 variant
						elif $bashbrewArch | startswith("arm32v") then
							{ GOARCH: "arm", GOARM: ($bashbrewArch | ltrimstr("arm32v")) }
						else {} end
				| if $bashbrewArch == "src" then del(.value.env) else . end
			)
		),
		variants: [
			"bookworm",
			"bullseye",
			(
				"3.19",
				"3.18",
				empty
			| "alpine" + .),
			if .arches | has("windows-amd64") and .["windows-amd64"].url then
				(
					"ltsc2022",
					"1809",
					empty
				| "windows/windowsservercore-" + .),
				(
					"ltsc2022",
					"1809",
					empty
				| "windows/nanoserver-" + .)
			else empty end
		],
	}')"

	json="$(jq <<<"$json" -c --argjson doc "$doc" '.[env.version] = $doc')"
done

jq <<<"$json" '
	def sort_keys:
		to_entries
		| sort_by(.key)
		| from_entries
	;
	sort_keys
	| .[].arches |= sort_keys
' > versions.json
