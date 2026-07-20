import Foundation
import SampleViews
import SnapshotTestingMacros
import SwiftUI
import Testing

/*
 Where a reference lands on disk, asserted from outside the library.

 This is the contract adopters actually depend on and the one the library cannot check
 on itself: reference paths are resolved relative to the *calling* test file, so the
 library's own suites can only ever prove the layout works for files inside the library.
 A consumer proves it works for everyone else.

 It matters because the path is a compatibility surface. When the v3 layout changed,
 every existing adopter's references were orphaned — and because a missing reference
 records rather than fails, their suites went green while comparing against files
 written moments earlier. A silent re-record is indistinguishable from a pass, so the
 path is worth pinning explicitly rather than trusting a green suite.

 Each test writes its own reference and then asserts where it went, so nothing depends
 on another test having run first.
 */
@Suite(.theme(.light), .sizes(.minimum))
struct ReferenceNamingContract {
  @Test
  func namedSnapshotLandsUnderTheTestFilesSnapshotFolder() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "contract-simple")
    }

    expectReference(at: "contract-simple_min-size_light.1.png")
  }

  @Test
  func slashDelimitedNameNestsASubfolderAndKeepsTheTrailingComponentAsTheArtifact() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "Section/contract-nested")
    }

    expectReference(at: "Section/contract-nested_min-size_light.1.png")
  }

  @Test(.sizes(width: 160, height: 80))
  func fixedSizeEncodesItsGeometryInTheFileName() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "contract-fixed")
    }

    expectReference(at: "contract-fixed_fixed-160x80_light.1.png")
  }

  @Test(.sizes(width: 160, height: 80, scale: 2))
  func explicitScaleIsAppendedAsItsOwnField() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "contract-scaled")
    }

    expectReference(at: "contract-scaled_fixed-160x80-2x_light.1.png")
  }

  @Test(.theme(.all))
  func eachThemeGetsItsOwnReference() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "contract-themed")
    }

    expectReference(at: "contract-themed_min-size_light.1.png")
    expectReference(at: "contract-themed_min-size_dark.1.png")
  }
}

/// Asserts a reference exists at `__Snapshots__/ReferenceNamingContract/<relativePath>`,
/// resolved from this file's own location exactly as the library resolves it.
private func expectReference(
  at relativePath: String,
  fileID: String = #fileID,
  filePath: String = #filePath,
  line: Int = #line,
  column: Int = #column
) {
  let snapshotsDirectory = URL(fileURLWithPath: filePath)
    .deletingLastPathComponent()
    .appendingPathComponent("__Snapshots__")
    .appendingPathComponent("ReferenceNamingContract")

  let reference = snapshotsDirectory.appendingPathComponent(relativePath)

  #expect(
    FileManager.default.fileExists(atPath: reference.path),
    "No reference at \(relativePath). The naming contract adopters depend on has changed.",
    sourceLocation: SourceLocation(
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  )
}
