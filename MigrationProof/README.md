# Migration Proof

Proves that a legacy `@SnapshotSuite` / `@SnapshotTest` suite migrates to the native API and
then **compiles against the new library** — the migration path working end to end, in CI, for
real.

## Why compile is the proof

The deprecated macros expand to non-static `@used` / `@section` properties that Xcode 26.4+
rejects, so a legacy suite no longer builds at all on current toolchains. That is the whole
reason the migrator exists. So a legacy suite that **compiles after migration** is the value
proposition demonstrated literally: broken → migrate → builds.

Runtime and pixels are not the job here — the library's own integration suites cover those, on
pinned runtimes with committed references. This proves the *code* migration lands.

## What it covers

`Legacy/LegacyShowcase.swift.fixture` is a representative suite on the widest released old-macro
surface (2.x / 3.0.0): suite- and test-level traits, `.padding` / `.backgroundColor` decoration,
both `configurationValues:` and `configurations:` parameterisation, a native Swift Testing trait
(`.tags`), and a nested subsuite. One package is enough because the legacy public API barely
changed across versions — later releases only *added* traits, so this superset covers the earlier
ones. (`.timeLimit` is omitted only because it is `@available(iOS 16+)` while this package targets
the library's iOS 15 floor; its migration is covered by the migrator's own unit test.)

It is a `.fixture`, not a `.swift`, precisely because it cannot compile until it is migrated.

## Running it

```shell
# Needs a checkout of the migrator (defaults to a sibling directory).
./migrate-and-build.sh [path-to-migrator] [xcodebuild-destination]
```

The script copies the fixture into the test target, runs the **real** migrator CLI over it, then
builds the result — nothing about the transform is pre-baked. CI runs it on macOS and iOS across
Xcode 26.4 and 26.5.

The migrated `Tests/ShowcaseTests/*.swift` is generated and gitignored; the fixture is the only
committed source.
