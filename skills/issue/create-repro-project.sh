#!/bin/sh
# Creates a clean ES module project for a minimal reproduction, installs the
# named packages with pnpm, and prints the versions the reproduction runs
# against next to the latest published version of each.
# Usage: create-repro-project.sh <dir> <pkg>[@<version>]...
# Then write <dir>/repro.mjs and run it with `node <dir>/repro.mjs`.

set -eu

dir="${1:?usage: create-repro-project.sh <dir> <pkg>[@<version>]...}"
shift
[ $# -gt 0 ] || { echo "usage: create-repro-project.sh <dir> <pkg>[@<version>]..." >&2; exit 2; }

mkdir -p "$dir"
cd "$dir"
printf '{"name":"repro","private":true,"type":"module"}\n' > package.json
pnpm add --silent "$@"

echo "dir: $(pwd)"
echo "node: $(node --version)"
echo "os: $(uname -sm)"
for spec in "$@"; do
  rest="${spec#@}"
  name="${rest%%@*}"
  case "$spec" in @*) name="@$name" ;; esac
  installed=$(jq -r '.version' "node_modules/$name/package.json")
  latest=$(npm view "$name" version 2>/dev/null || echo '?')
  echo "$name: installed $installed, latest $latest"
done
