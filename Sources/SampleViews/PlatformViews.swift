#if canImport(UIKit)
import UIKit

/// A frame-based UIKit view, the shape a suite migrating from pointfree's
/// `assertSnapshot(of:as:)` most often has.
public final class BadgeView: UIView {
  public override var intrinsicContentSize: CGSize { CGSize(width: 48, height: 24) }

  public init() {
    super.init(frame: CGRect(x: 0, y: 0, width: 48, height: 24))
    backgroundColor = .systemBlue
    layer.cornerRadius = 4
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public final class BadgeController: UIViewController {
  public override func loadView() {
    view = BadgeView()
  }
}

#elseif canImport(AppKit)
import AppKit

/// The AppKit counterpart. macOS is a first-class rendering path in the library, so a
/// consumer that only ever exercised UIKit would leave half of it unproven.
public final class BadgeView: NSView {
  public override var intrinsicContentSize: NSSize { NSSize(width: 48, height: 24) }

  public init() {
    super.init(frame: NSRect(x: 0, y: 0, width: 48, height: 24))
    wantsLayer = true
    layer?.backgroundColor = NSColor.systemBlue.cgColor
    layer?.cornerRadius = 4
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public final class BadgeController: NSViewController {
  public override func loadView() {
    view = BadgeView()
  }
}
#endif
