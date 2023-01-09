// Copyright © 2021 Brad Howes. All rights reserved.

#if os(iOS)

import UIKit

internal extension UIColor {

  var extendedSRGB: UIColor { self }

  /// Obtain a darker variation of the current color
  var darker: Self {
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0
    extendedSRGB.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    return Self(hue: hue, saturation: saturation, brightness: brightness * 0.8, alpha: alpha)
  }
}

#endif
