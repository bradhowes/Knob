// Copyright © 2021 Brad Howes. All rights reserved.

#if os(macOS)

import AppKit

internal extension NSView {

  func setNeedsDisplay() { self.needsDisplay = true }
  func setNeedsLayout() { self.needsLayout = true }

  @objc func layoutSubviews() { self.layout() }

  var backgroundColor: NSColor? {
    get {
      guard let colorRef = self.layer?.backgroundColor else { return nil }
      return NSColor(cgColor: colorRef)
    }
    set {
      self.wantsLayer = true
      self.layer?.backgroundColor = newValue?.cgColor
    }
  }
}

#endif
