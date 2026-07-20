# swift-snapshot-testing-macros-sample

A minimal consumer of [swift-snapshot-testing-macros](https://github.com/adammcarter/swift-snapshot-testing-macros),
existing to test the things the library provably cannot test on itself.

## Why a separate package

Every test in the library runs *inside* the library. That leaves a blind spot no amount
of internal testing closes:

| Only visible from outside | Why the library can't catch it |
| --- | --- |
| A symbol that should be `public` but is `internal` | Works fine inside the module; breaks the first dependent |
| Macro plugin resolution from a dependent | The library builds its own plugin directly |
| Declared platform minimums | Never exercised by resolution against another manifest |
| Reference paths relative to the *caller* | The library can only prove the layout for its own files |

This package is that outside. It resolves the library as an ordinary SPM dependency and
uses only its public API.

## What is actually asserted

**`PublicAPISurface.swift`** exercises every documented public form — direct values,
`named:`, all four closure shapes, `argument:`, `SnapshotConfiguration`, every trait, and
the platform-native overloads. Its value is mostly in *compiling*: if this target builds,
the public surface is genuinely reachable and macro resolution from a dependent worked.

**`ReferenceNamingContract.swift`** pins where references land on disk. Each test writes
its own reference and then asserts the path, so a layout change fails here loudly instead
of silently orphaning every adopter's committed images.

## What this does NOT prove

**It does not verify pixels.** References are not committed here and `__Snapshots__` is
gitignored, so every run records fresh. That is deliberate — snapshot references are
bound to the runtime that recorded them, and a consumer package cannot hold a stable
reference environment without becoming a second copy of the library's recording
infrastructure.

Pixel fidelity is the library's own integration suites' job, where references are
recorded and verified on pinned CI runtimes.

Because references start absent, every snapshot assertion is wrapped in
`recordingOrVerifying`. Recording a missing reference **is** reported as an issue by the
library — it does not silently pass, which is the correct behaviour and worth stating
because some of the migration notes assumed otherwise. That wrapper accepts the cold-run
record and the warm-run verify alike.

So: these tests fail on **compilation** and on **paths**, never on image content. Do not
read a green run here as evidence that rendering is correct.

The path assertions are deliberately falsifiable — point one at a name the library does
not produce and the suite goes red with the expected and actual path. A contract test
that cannot fail is worse than no test, so that property is worth re-checking if these
are ever refactored.

## Running

```shell
swift test
```

CI builds and tests on both macOS and iOS, because each platform compiles out the other's
sources and neither substitutes for the other.
