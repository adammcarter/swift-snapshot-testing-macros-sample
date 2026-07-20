import SwiftUI

/// A SwiftUI view with enough structure to be worth snapshotting, and none of the
/// dependencies a real app would drag in.
public struct ProfileCard: View {
  private let name: String
  private let subtitle: String

  public init(name: String = "Sample", subtitle: String = "Consumer") {
    self.name = name
    self.subtitle = subtitle
  }

  public var body: some View {
    HStack(spacing: 8) {
      Circle()
        .fill(.tint)
        .frame(width: 24, height: 24)

      VStack(alignment: .leading, spacing: 2) {
        Text(name).font(.headline)
        Text(subtitle).font(.caption).foregroundStyle(.secondary)
      }
    }
    .padding(8)
  }
}

/// CardLayout and user state, so parameterised snapshots have something real to vary.
public enum CardLayout: String, CaseIterable, Sendable {
  case compact
  case regular
}

public enum CardState: String, CaseIterable, Sendable {
  case loggedIn
  case loggedOut
}

public struct StatefulCard: View {
  private let layout: CardLayout
  private let state: CardState

  public init(layout: CardLayout, state: CardState) {
    self.layout = layout
    self.state = state
  }

  public var body: some View {
    ProfileCard(
      name: state == .loggedIn ? "Signed in" : "Signed out",
      subtitle: layout.rawValue
    )
  }
}
