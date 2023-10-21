// Copyright © 2021 Brad Howes. All rights reserved.

#if os(macOS)

import AppKit

internal extension NSBezierPath {

  func apply(_ transform: CGAffineTransform) {
    self.transform(using: .init(m11: transform.a, m12: transform.b, m21: transform.c, m22: transform.d,
                                tX: transform.tx, tY: transform.ty))
  }

  var cgPath: CGPath {
    let path = CGMutablePath()
    var points = [CGPoint](repeating: .zero, count: 3)
    for index in 0 ..< self.elementCount {
      let type = self.element(at: index, associatedPoints: &points)
      switch type {
      case .moveTo: path.move(to: points[0])
      case .lineTo: path.addLine(to: points[0])
      case .curveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
      case .closePath: path.closeSubpath()
      case .cubicCurveTo: break
      case .quadraticCurveTo: break
      @unknown default: break
      }
    }
    return path
  }
}

#endif
