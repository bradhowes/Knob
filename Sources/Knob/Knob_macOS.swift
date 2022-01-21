#if os(macOS)

import AppKit

extension Knob {

  /**
   Set the value of the knob.

   - parameter value: the new value to use
   - parameter animated: true if animating the change to the new value
   */
  public func setValue(_ value: Float, animated: Bool = false) {
    _value = clampedValue(value)
    draw(animated: animated)
    updateLayer()
    restorationTimer?.invalidate()
    valueLabel?.string = formattedValue
  }
}

// MARK: - Label updating

extension Knob {

  open func restoreLabelWithName() {
    notifyTarget()
    restorationTimer?.invalidate()
    guard
      let valueLabel = self.valueLabel,
      let valueName = self.valueName
    else { return }

    restorationTimer = Timer.scheduledTimer(withTimeInterval: valuePersistence, repeats: false) { [weak self] _ in
      guard let self = self else { return }
      self.performRestoration(label: valueLabel, value: valueName)
    }
  }

  internal func performRestoration(label: Label, value: String) {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = nameTransitionDuration
      label.animator().string = value
    }) {
      label.animator().string = value
    }
  }
}

// MARK: - Layout

extension Knob {

  /**
   Reposition layers to reflect new size.
   */
  public override func layout() {
    super.layout()
    doLayoutSubviews()
  }

  internal func doLayoutSubviews() {

    // To make future calculations easier, configure the layers so that (0, 0) is their center
    let layerBounds = bounds.offsetBy(dx: -bounds.midX, dy: -bounds.midY)
    let layerCenter = CGPoint(x: bounds.midX, y: bounds.midY)
    for layer in [trackLayer, progressLayer, indicatorLayer, ticksLayer] {
      layer.bounds = layerBounds
      layer.position = layerCenter
    }
    createShapes()
  }
}

// MARK: - Event Tracking

extension Knob {

  override public func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    return true
  }

  override open func mouseDown(with event: NSEvent) {
    panOrigin = convert(event.locationInWindow, from: nil)
    manipulating = true
    notifyTarget()
  }

  override open func mouseDragged(with event: NSEvent) {
    guard manipulating == true else { return }
    updateValue(with: convert(event.locationInWindow, from: nil))
  }

  override open func mouseUp(with event: NSEvent) {
    manipulating = false
    restoreLabelWithName()
  }
}

extension Knob : NSAccessibilitySlider {
  public override func isAccessibilityElement() -> Bool { true }
  public override func isAccessibilityEnabled() -> Bool { true }
}

// MARK: - Private

extension Knob {

  internal var maxChangeRegionWidthHalf: CGFloat { min(4, travelDistance * maxChangeRegionWidthPercentage) / 2 }
  internal var halfTravelDistance: CGFloat { travelDistance / 2 }

  internal func updateValue(with point: CGPoint) {
    defer { panOrigin = CGPoint(x: panOrigin.x, y: point.y) }

    // dX should never be equal to or greater than minDimensionHalf
    let dX = min(abs(bounds.midX - point.x), halfTravelDistance - 1)
    let dY = panOrigin.y - point.y

    // Scale Y changes by how far away in the X direction the touch is -- farther away the more one must travel in Y
    // to achieve the same change in value. Use `touchSensitivity` to increase/reduce this effect.
    //
    // - if the touch/mouse is <= maxChangeRegionWidthHalf pixels from the center X then scaleT is 1.0
    // - otherwise, it linearly gets smaller as X moves away from the center
    //
    let scaleT = dX <= maxChangeRegionWidthHalf ? 1.0 : (1.0 - dX / halfTravelDistance)
    print(dX, scaleT)

    let deltaT = Float((dY * scaleT) / (travelDistance * touchSensitivity))
    let change = deltaT * (maximumValue - minimumValue)
    self.value += change
    notifyTarget()
  }

  internal func notifyTarget() {
    updateQueue.async { self.sendAction(self.action, to: self.target) }
  }
}

extension Knob {

  internal func initialize() {
    layer = CALayer()
    wantsLayer = true

    backingLayer.drawsAsynchronously = true
    trackLayer.drawsAsynchronously = true
    progressLayer.drawsAsynchronously = true
    indicatorLayer.drawsAsynchronously = true
    ticksLayer.drawsAsynchronously = true

    backingLayer.addSublayer(ticksLayer)
    backingLayer.addSublayer(trackLayer)
    backingLayer.addSublayer(progressLayer)
    backingLayer.addSublayer(indicatorLayer)

    trackLayer.fillColor = KnobColor.clear.cgColor
    progressLayer.fillColor = KnobColor.clear.cgColor
    indicatorLayer.fillColor = KnobColor.clear.cgColor
    ticksLayer.fillColor = KnobColor.clear.cgColor

    trackLayer.lineWidth = trackLineWidth
    trackLayer.strokeColor = trackColor.cgColor
    trackLayer.lineCap = .round
    trackLayer.strokeStart = 0.0
    trackLayer.strokeEnd = 1.0

    progressLayer.lineWidth = progressLineWidth
    progressLayer.strokeColor = progressColor.cgColor
    progressLayer.lineCap = .round
    progressLayer.strokeStart = 0.0
    progressLayer.strokeEnd = 0.0

    indicatorLayer.lineWidth = indicatorLineWidth
    indicatorLayer.strokeColor = indicatorColor.cgColor
    indicatorLayer.lineCap = .round

    ticksLayer.lineWidth = tickLineWidth
    ticksLayer.strokeColor = tickColor.cgColor
    ticksLayer.lineCap = .round
  }

  internal func createShapes() {
    createTrack()
    createIndicator()
    createTicks()
    createProgressTrack()

    draw(animated: false)
  }

  internal func createRing() -> BezierPath {
    let ring = BezierPath()
    var points = [CGPoint]()
    for theta in 0...270 {
      let x = radius * cos(CGFloat(theta) * .pi / 180.0)
      let y = radius * sin(CGFloat(theta) * .pi / 180.0)
      points.append(CGPoint(x: x, y: y))
    }

    ring.appendPoints(&points, count: points.count)
    ring.apply(CGAffineTransform(rotationAngle: CGFloat.pi / 180.0 * (90 + 45)))

    return ring
  }

  internal func createTrack() {
    let ring = createRing()
    trackLayer.path = ring.cgPath

  }

  internal func createIndicator() {
    let indicator = BezierPath()
    indicator.move(to: CGPoint(x: radius, y: 0.0))
    indicator.line(to: CGPoint(x: radius * (1.0 - indicatorLineLength), y: 0.0))
    indicatorLayer.path = indicator.cgPath
  }

  internal func createProgressTrack() {
    let progressRing = createRing()
    progressLayer.path = progressRing.cgPath
  }

  internal func createTicks() {
    let ticks = BezierPath()
    for tickIndex in 0..<tickCount {
      let tick = BezierPath()
      let theta = angle(for: Float(tickIndex) / max(1.0, Float(tickCount - 1)))
      tick.move(to: CGPoint(x: 0.0 + radius * (1.0 - tickLineOffset), y: 0.0))
      tick.addLine(to: CGPoint(x: 0.0 + radius * (1.0 - tickLineLength), y: 0.0))
      tick.apply(CGAffineTransform(rotationAngle: theta))
      ticks.append(tick)
    }
    ticksLayer.path = ticks.cgPath
  }

  internal func draw(animated: Bool = false) {
    if manipulating || !animated { CATransaction.setDisableActions(true) }
    progressLayer.removeAllAnimations()
    indicatorLayer.removeAllAnimations()
    progressLayer.strokeEnd = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
    indicatorLayer.transform = CATransform3DMakeRotation(angleForValue, 0, 0, 1)
  }

  internal var radius: CGFloat { (min(trackLayer.bounds.width, trackLayer.bounds.height) / 2) - trackLineWidth }

  internal var angleForValue: CGFloat { angle(for: (self.value - minimumValue) / (maximumValue - minimumValue)) }

  internal func angle(for normalizedValue: Float) -> CGFloat {
    CGFloat(normalizedValue) * (endAngle - startAngle) + startAngle
  }

  internal func clampedValue(_ value: Float) -> Float { min(maximumValue, max(minimumValue, value)) }
}

#endif
