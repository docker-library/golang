#!/usr/bin/env bash
set -Eeuo pipefail

# we use this to munge "versions.json" to force building on all arches
versionsMunge='.[].arches |= with_entries(if .key != "src" then del(.value.url, .value.sha256) else . end)'
export versionsMunge

jq '
	.matrix.include += [
		.matrix.include[]
		| select(.name | test(" (.+)") | not) # ignore any existing munged builds
		| select(.os | startswith("windows-") | not) # ignore Windows (always downloads)
		| select(any(.meta.entries[].tags[]; contains("golang:1.20"))) # https://github.com/docker-library/golang/pull/500#issuecomment-1863578601
		| .name += " (force build)"
		| .runs.build = ([
			"# update versions.json to force us to build Go instead of downloading it",
			"jq " + (env.versionsMunge | @sh) + " versions.json | tee versions.munged.json",
			"mv versions.munged.json versions.json",
			"./apply-templates.sh",
			"git diff",
			.runs.build
		] | join("\n"))
	]
' "$@"
