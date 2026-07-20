import SampleViews
import SnapshotTestingMacros
import SwiftUI
import Testing

/*
 Every documented public form, used the way an adopter uses it: through a resolved
 package dependency, with only `public` symbols in reach.

 The library cannot test this on itself. Its own suites compile inside the module, so a
 symbol that should be `public` but is only `internal` still works there and breaks the
 first time somebody depends on it. That is a whole class of release defect this file
 catches by doing nothing more than compiling.

 The assertions themselves are secondary here. If this target builds and runs, macro
 plugin resolution from a dependent worked, the platform minimums were satisfied, and
 every form below is genuinely reachable from outside.
 */
@Suite(.theme(.all), .sizes(.minimum))
struct PublicAPISurface {
  @Test
  func directValue() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard())
    }
  }

  @Test
  func namedSnapshot() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "named-card")
    }
  }

  @Test("Display name differs from artifact name")
  func displayName() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "display-name-card")
    }
  }

  @Test
  func slashDelimitedNameNestsASubfolder() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "Nested/card")
    }
  }

  @Test
  func syncClosure() {
    recordingOrVerifying {
      #expectSnapshot(named: "sync-closure") {
        ProfileCard()
      }
    }
  }

  @Test
  func throwingClosure() throws {
    try recordingOrVerifying {
      try #expectSnapshot(named: "throwing-closure") {
        ProfileCard()
      }
    }
  }

  @Test
  func asyncClosure() async {
    await recordingOrVerifying {
      await #expectSnapshot(named: "async-closure") {
        ProfileCard()
      }
    }
  }

  @Test
  func asyncThrowingClosure() async throws {
    try await recordingOrVerifying {
      try await #expectSnapshot(named: "async-throwing-closure") {
        ProfileCard()
      }
    }
  }

  @Test(arguments: CardLayout.allCases)
  func parameterisedByArgument(layout: CardLayout) {
    recordingOrVerifying {
      #expectSnapshot(argument: layout, named: "by-argument") { layout in
        StatefulCard(layout: layout, state: .loggedIn)
      }
    }
  }

  @Test(
    arguments: [
      SnapshotConfiguration(name: "compact-out", value: (CardLayout.compact, CardState.loggedOut)),
      SnapshotConfiguration(name: "regular-in", value: (CardLayout.regular, CardState.loggedIn)),
    ]
  )
  func parameterisedByConfiguration(configuration: SnapshotConfiguration<(CardLayout, CardState)>) {
    recordingOrVerifying {
      #expectSnapshot(configuration) { layout, state in
        StatefulCard(layout: layout, state: state)
      }
    }
  }
}

/// Traits, applied the way the documentation describes them.
@Suite(.sizes(.minimum))
struct PublicTraitSurface {
  @Test(.theme(.light))
  func themeTrait() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "theme-light")
    }
  }

  @Test(.padding(8))
  func paddingTrait() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "padded")
    }
  }

  @Test(.sizes(width: 120, height: 60, scale: 2))
  func explicitSizeTrait() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "fixed-size")
    }
  }

  @Test(.theme(.dark), .padding(4))
  func composedTraits() {
    recordingOrVerifying {
      #expectSnapshot(ProfileCard(), named: "dark-padded")
    }
  }
}

/// The platform-native overloads, on whichever platform is being built.
@MainActor
@Suite(.theme(.light), .sizes(.minimum))
struct PublicPlatformSurface {
  @Test
  func platformView() {
    recordingOrVerifying {
      #expectSnapshot(BadgeView(), named: "platform-view")
    }
  }

  @Test
  func platformController() {
    recordingOrVerifying {
      #expectSnapshot(BadgeController(), named: "platform-controller")
    }
  }
}
