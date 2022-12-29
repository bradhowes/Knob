// Copyright © 2022 Brad Howes. All rights reserved.

#if os(macOS)

import AppKit

public extension NSColor {

  convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    self.init(deviceRed: red, green: green, blue: blue, alpha: alpha)
  }

  var extendedSRGB: NSColor { usingColorSpace(.extendedSRGB) ?? self }

  var darker: NSColor {
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0
    extendedSRGB.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return Self(hue: hue, saturation: saturation, brightness: brightness * 0.8, alpha: alpha)
  }
}

#endif
