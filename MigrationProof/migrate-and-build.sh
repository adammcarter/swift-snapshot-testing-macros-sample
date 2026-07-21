#!/bin/zsh
# Proves an old-macro suite migrates and then compiles against the new library.
#
# Copies the legacy fixture into the test target, runs the *real* migrator over it, then builds
# the result. A clean build is the proof: the deprecated macros do not compile on Xcode 26.4+, so
# "migrated → compiles" is exactly the value the migrator promises.
#
# Usage: migrate-and-build.sh [path-to-migrator-checkout] [xcodebuild-destination]
#   migrator path  defaults to a sibling checkout of swift-snapshot-testing-macros-migrator.
#   destination    defaults to 'platform=macOS'; pass an iOS Simulator destination to prove iOS.

set -euo pipefail
setopt NULL_GLOB   # an empty target dir is normal; a no-match glob must not abort the run

here="${0:A:h}"
migrator="${${1:-$here/../../swift-snapshot-testing-macros-migrator}:A}"   # absolutise
destination="${2:-platform=macOS}"

if [[ ! -f "$migrator/Package.swift" ]]; then
  print -u2 "migrator package not found at: $migrator"
  print -u2 "pass its path as the first argument, or check it out as a sibling."
  exit 1
fi

# xcodebuild resolves the scheme from the working directory, so run from the package root.
cd "$here"

target_dir="$here/Tests/ShowcaseTests"

# Start from the committed fixture every run, so a stale migrated copy never masks a regression.
rm -f "$target_dir"/*.swift
for fixture in "$here"/Legacy/*.swift.fixture; do
  cp "$fixture" "$target_dir/$(basename "${fixture%.fixture}")"
done

# Migrate in place. --fail-on-skips makes an unmigrated declaration a hard failure rather than a
# silently skipped one.
swift run --package-path "$migrator" snapshot-migrate \
  --project-root "$here" \
  --apply \
  --fail-on-skips

# The build is the assertion. Nothing to record or run: the migrated code either compiles against
# the new library's native API or it does not. `-skipMacroValidation` is required because no one
# can approve the macro's Trust & Enable prompt on a runner.
xcodebuild build-for-testing \
  -scheme MigrationProof-Package \
  -destination "$destination" \
  -skipMacroValidation

print "migrate-and-build: migrated output compiles against the new library ($destination)."
