// Copyright © 2021 Brad Howes. All rights reserved.

#if os(macOS)

import AppKit

public extension NSTextField {
  var text: String? {
    get { self.stringValue }
    set { self.stringValue = newValue ?? "" }
  }
}

#endif
