// Copyright © 2022 Brad Howes. All rights reserved.

#if os(macOS)

import AppKit

public extension NSColor {

  convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    self.init(deviceRed: red, green: green, blue: blue, alpha: alpha)
  }

  convenience init(hex: String, alpha: CGFloat = 1.0) {
    var hexFormatted = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    if hexFormatted.hasPrefix("#") {
      hexFormatted = String(hexFormatted.dropFirst())
    }

    precondition(hexFormatted.count == 6, "Invalid hex code used.")

    var rgbValue: UInt64 = 0
    Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: alpha)
  }

  var extendedSRGB: NSColor {
    return usingColorSpace(.extendedSRGB) ?? self
  }

  /// Obtain a darker variation of the current color
  var darker: NSColor {
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0
    extendedSRGB.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return Self(hue: hue, saturation: saturation, brightness: brightness * 0.8, alpha: alpha)
  }

  /// Obtain a lighter variation of the current color
  var lighter: NSColor {
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0
    extendedSRGB.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return Self(hue: hue, saturation: saturation, brightness: brightness * 1.2, alpha: alpha)
  }
}

#endif
