// Copyright © 2021 Brad Howes. All rights reserved.

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

internal extension Knob.KnobColor {

#if os(macOS)
  convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    self.init(deviceRed: red, green: green, blue: blue, alpha: alpha)
  }
#endif

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

  var extendedSRGB: Knob.KnobColor {
#if os(macOS)
    return usingColorSpace(.extendedSRGB) ?? self
#else
    return self
#endif
  }

  /// Obtain a darker variation of the current color
  var darker: Knob.KnobColor {
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0
    extendedSRGB.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return Self(hue: hue, saturation: saturation, brightness: brightness * 0.8, alpha: alpha)
  }

  /// Obtain a lighter variation of the current color
  var lighter: Knob.KnobColor {
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0
    extendedSRGB.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return Self(hue: hue, saturation: saturation, brightness: brightness * 1.2, alpha: alpha)
  }
}
