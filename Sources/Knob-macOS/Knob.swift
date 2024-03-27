// Copyright © 2023 Brad Howes. All rights reserved.

#if os(macOS)

import AppKit

/**
 Custom UIControl/NSControl that depicts a value as a point on a circle. Changing the value is done by touching on the
 control and moving up to increase and down to decrease the current value. While touching, moving away from the control
 in either direction will increase the resolution of the touch changes, causing the value to change more slowly as
 vertical distance changes. Pretty much works like UISlider but with the travel path as an arc.

 Visual representation of the knob is done via CoreAnimation components, namely CAShapeLayer and UIBezierPath. The
 diameter of the arc of the knob is defined by the min(width, height) of the view's frame. The start and end of the arc
 is controlled by the `startAngle` and `endAngle` settings.
 */
open class Knob: NSControl {

  /// The minimum value reported by the control.
  public var minimumValue: Float = 0.0 {
    didSet {
      if minimumValue >= maximumValue { maximumValue = minimumValue + 1.0 }
      setValue(_normalizedValue * (maximumValue - oldValue) + oldValue)
    }
  }

  /// The maximum value reported by the control.
  public var maximumValue: Float = 1.0 {
    didSet {
      if maximumValue <= minimumValue { minimumValue = maximumValue - 1.0 }
      setValue(_normalizedValue * (oldValue - minimumValue) + minimumValue)
    }
  }

  /// The current value of the control, expressed in a value between `minimumValue` and `maximumValue`
  @objc public dynamic var value: Float {
    get { _normalizedValue * (maximumValue - minimumValue) + minimumValue }
    set { setValue(newValue) }
  }

  @objc public dynamic var currentValue: Float { value }

  /// The distance in pixels used for calculating mouse/touch changes to the knob value. By default, use the smaller of
  /// the view's width and height.
  open var travelDistance: CGFloat { (min(bounds.height, bounds.width)) }

  /// How much travel is need to change the knob from `minimumValue` to `maximumValue`.
  /// By default this is 1x the `travelDistance` value. Setting it to 2 will require 2x the `travelDistance` to go from
  /// `minimumValue` to `maximumValue`.
  public var touchSensitivity: CGFloat = 1.0

  /// Percentage of `travelDistance` where a touch/mouse event will perform maximum value change. This defines a
  /// vertical region in the middle of the view. Events outside of this region will have finer sensitivity and control
  /// over value changes.
  public var maxChangeRegionWidthPercentage: CGFloat = 0.1

  /// Controls the width of the track arc that is shown behind the progress track. The track with will be the smaller of
  /// the width/height of the bounds times this value.
  public var trackWidthFactor: CGFloat = 0.08 { didSet { trackLayer.setNeedsDisplay() } }

  /// The color of the arc shown after the current value.
  public var trackColor: NSColor = .darkGray.darker.darker.darker { didSet { trackLayer.setNeedsDisplay() } }

  /// Controls the width of the progress arc that is shown on top of the track arc. The width with will be the smaller
  /// of the width/height of the bounds times this value. See `trackWidthFactor`.
  public var progressWidthFactor: CGFloat = 0.055 { didSet { progressLayer.setNeedsDisplay() } }

  /// The color of the arc from the start up to the current value.
  public var progressColor: NSColor = .init(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
  { didSet { progressLayer.setNeedsDisplay() } }

  /// The width of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorWidthFactor: CGFloat = 0.055 { didSet { indicatorLayer.setNeedsDisplay() } }

  /// The color of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorColor: NSColor = .init(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
  { didSet { indicatorLayer.setNeedsDisplay() } }

  /// The proportion of the radial line drawn from the current value on the arc towards the arc center.
  /// Range is from 0.0 to 1.0, where 1.0 will draw a complete line, and anything less will draw that fraction of it
  /// starting from the arc.
  public var indicatorLineLength: CGFloat = 0.3 { didSet { indicatorLayer.setNeedsDisplay() } }

  /// Number of ticks to show inside the track, with the first indicating the `minimumValue` and the last indicating
  /// the `maximumValue`
  public var tickCount: Int = 0 { didSet { ticksLayer.setNeedsDisplay() } }

  /// Offset for the start of a tick line. Range is from 0.0 to 1.0 where 0.0 starts at the circumference of the arc,
  /// and 0.5 is midway between the circumference and the center along a radial.
  public var tickLineOffset: CGFloat = 0.1 { didSet { ticksLayer.setNeedsDisplay() } }

  /// Length of the tick. Range is from 0.0 to 1.0 where 1.0 will draw a line ending at the center of the knob.
  public var tickLineLength: CGFloat = 0.2 { didSet { ticksLayer.setNeedsDisplay() } }

  /// The width of the tick line.
  public var tickLineWidth: CGFloat = 1.0 { didSet { ticksLayer.setNeedsDisplay() } }

  /// The color of the tick line.
  public var tickColor: NSColor = .black { didSet { ticksLayer.setNeedsDisplay() } }

  public var backgroundColor: NSColor {
    get { return NSColor(cgColor: backingLayer.backgroundColor ?? .clear) ?? .clear }
    set { backingLayer.backgroundColor = newValue.cgColor }
  }

  /// The text element to use to show the knob's value and name.
  public var valueLabel: NSTextField?

  /// The name to show when the knob is not being manipulated. If nil, the knob's value is always shown.
  public var valueName: String?

  /// The formatter to use to generate a textual representation of the knob's current value. If nil, use Swift's default
  /// formatting for floating-point numbers.
  public var valueFormatter: NumberFormatter?

  /// Time to show the last value once manipulation has ceased, before the name is shown.
  public var valuePersistence: TimeInterval = 1.0

  /// Duration of the animation used when transitioning from the value to the name in the label. Value of 0.0 implies no
  /// animation.
  public var nameTransitionDuration = 0.5

  /// Obtain a formatted value of the knob's current value.
  public var formattedValue: String { valueFormatter?.string(from: .init(value: value)) ?? "\(value)" }

  /// Obtain the manipulating state of the knob. This is `true` during a touch event or a mouse-down event, and it goes
  /// back to `false` once the event ends.
  public private(set) var manipulating = false

  /**
   The starting angle of the arc where a value of 0.0 is located. Arc angles are explained in the UIBezier
   documentation for init(arcCenter:radius:startAngle:endAngle:clockwise:). In short, a value of 0.0 will start on
   the positive X axis, a positive PI/2 will lie on the negative Y axis. The default values will leave a 90° gap at
   the bottom.
   */
  public var startAngle: CGFloat = -.pi / 180.0 * 225.0 {
    didSet {
      trackLayer.setNeedsDisplay()
      progressLayer.setNeedsDisplay()
      indicatorLayer.setNeedsDisplay()
      ticksLayer.setNeedsDisplay()
    }
  }

  /// The ending angle of the arc where a value of 1.0 is located. See `startAngle` for additional info.
  public var endAngle: CGFloat = .pi / 180.0 * 45.0 {
    didSet {
      trackLayer.setNeedsDisplay()
      progressLayer.setNeedsDisplay()
      indicatorLayer.setNeedsDisplay()
      ticksLayer.setNeedsDisplay()
    }
  }

  private let trackLayer = CAShapeLayer()
  private let progressLayer = CAShapeLayer()
  private let indicatorLayer = CAShapeLayer()
  private let ticksLayer = CAShapeLayer()
  private let updateQueue = DispatchQueue(label: "KnobUpdates", qos: .userInteractive, attributes: [],
                                          autoreleaseFrequency: .inherit, target: .main)

  private var _normalizedValue: Float = 0.0
  private var panOrigin: CGPoint = .zero
  private var restorationTimer: Timer?
  private var backingLayer: CALayer { layer! }

  private var expanse: CGFloat { min(bounds.width, bounds.height) }
  private var radius: CGFloat { expanse / 2 - trackLineWidth }
  private var angleForNormalizedValue: CGFloat { angle(for: _normalizedValue) }

  private var trackLineWidth: CGFloat { expanse * trackWidthFactor }
  private var progressLineWidth: CGFloat { expanse * progressWidthFactor }
  private var indicatorLineWidth: CGFloat { expanse * indicatorWidthFactor }

  private func angle(for normalizedValue: Float) -> CGFloat {
    .init(normalizedValue) * (endAngle - startAngle) + startAngle
  }

  private func clampedValue(_ value: Float) -> Float { min(maximumValue, max(minimumValue, value)) }
  private func normalizedValue(_ value: Float) -> Float { (value - minimumValue) / (maximumValue - minimumValue) }

  override public var acceptsFirstResponder: Bool { get { true } }
  override public var isFlipped: Bool { true }

  override public var tag: Int {
    get { tag_ }
    set { tag_ = newValue }
  }

  private var tag_: Int = -1

  /**
   Construction from an encoded representation.

   - parameter aDecoder: the representation to use
   */
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  /**
   Construct a new instance with the given location and size. A knob will take the size of the smaller of width and
   height dimensions given in the `frame` parameter.

   - parameter frame: geometry of the new knob
   */
  public override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  public override func makeBackingLayer() -> CALayer {
    let layer = CAShapeLayer()
    layer.layoutManager = CAConstraintLayoutManager()
    return layer
  }
}

// MARK: - Setting Value

extension Knob {

  /**
   Set the value of the knob.

   - parameter value: the new value to use
   */
  public func setValue(_ value: Float) {
    _normalizedValue = normalizedValue(clampedValue(value))
    restorationTimer?.invalidate()
    valueLabel?.stringValue = formattedValue
    progressLayer.setNeedsDisplay()
    indicatorLayer.setNeedsDisplay()
  }
}

// MARK: - CALayerDelegate

extension Knob: CALayerDelegate {

  public func display(_ layer: CALayer) {
    if layer === trackLayer {
      trackLayer.lineWidth = trackLineWidth
      trackLayer.strokeColor = trackColor.cgColor
      trackLayer.path = createRing().cgPath
    } else if layer === progressLayer {
      progressLayer.lineWidth = progressLineWidth
      progressLayer.strokeColor = progressColor.cgColor
      progressLayer.path = createRing().cgPath
      progressLayer.strokeEnd = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
    } else if layer === ticksLayer {
      ticksLayer.lineWidth = tickLineWidth
      ticksLayer.strokeColor = tickColor.cgColor
      createTicks()
    } else if layer === indicatorLayer {
      indicatorLayer.lineWidth = indicatorLineWidth
      indicatorLayer.strokeColor = indicatorColor.cgColor
      createIndicator()
    }
  }
}

// MARK: - Label updating

extension Knob {

  public func restoreLabelWithName() {
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

  private func performRestoration(label: NSTextField, value: String) {
      NSAnimationContext.runAnimationGroup({ context in
        context.duration = nameTransitionDuration
        label.animator().stringValue = value
      }) {
        label.animator().stringValue = value
      }
  }
}

// MARK: - Event Tracking

extension Knob {
  override public func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
  override open func mouseDown(with event: NSEvent) { beginMove(with: convert(event.locationInWindow, from: nil)) }
  override open func mouseDragged(with event: NSEvent) { move(to: convert(event.locationInWindow, from: nil)) }
  override open func mouseUp(with event: NSEvent) { endMove() }
}

extension Knob : NSAccessibilitySlider {
  public override func isAccessibilityElement() -> Bool { true }
  public override func isAccessibilityEnabled() -> Bool { true }

  // Value is a NSString or a NSNumber
  override public func accessibilityValue() -> Any? {
    return NSNumber(value: value)
  }

  override public func accessibilityPerformIncrement() -> Bool {
    guard value < maximumValue else { return false }
    value += 1.0
    return true
  }

  override public func accessibilityPerformDecrement() -> Bool {
    guard value > minimumValue else { return false }
    value -= 1.0
    return true
  }
}

// MARK: - Private

extension Knob {

  private var maxChangeRegionWidthHalf: CGFloat { min(4, travelDistance * maxChangeRegionWidthPercentage) / 2 }
  private var halfTravelDistance: CGFloat { travelDistance / 2 }

  internal func beginMove(with point: CGPoint) {
    panOrigin = point
    manipulating = true
    notifyTarget()
  }

  internal func move(to point: CGPoint) {
    guard manipulating == true else { return }
    updateValue(with: point)
  }

  internal func endMove() {
    manipulating = false
    restoreLabelWithName()
  }

  /// Made internal for testing
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
    let deltaT = Float((dY * scaleT) / (travelDistance * touchSensitivity))
    let change = deltaT * (maximumValue - minimumValue)
    self.value += change
    notifyTarget()
  }

  private func notifyTarget() {
    updateQueue.async { self.sendAction(self.action, to: self.target) }
  }
}

extension Knob {

  private func initialize() {
    wantsLayer = true
    backingLayer.backgroundColor = .clear

    let leftConstraint = CAConstraint(attribute: .minX, relativeTo: "superlayer", attribute: .minX)
    let rightConstraint = CAConstraint(attribute: .maxX, relativeTo: "superlayer", attribute: .maxX)
    let bottomConstraint = CAConstraint(attribute: .minY, relativeTo: "superlayer", attribute: .minY)
    let topConstraint = CAConstraint(attribute: .maxY, relativeTo: "superlayer", attribute: .maxY)

    for layer in [trackLayer, ticksLayer, progressLayer, indicatorLayer] {
      backingLayer.addSublayer(layer)
      layer.needsDisplayOnBoundsChange = true
      layer.delegate = self
      layer.autoresizingMask = [] // .layerHeightSizable, .layerWidthSizable]
      layer.constraints = [leftConstraint, rightConstraint, bottomConstraint, topConstraint]
      layer.fillColor = .clear
      layer.backgroundColor = .clear
      layer.allowsEdgeAntialiasing = true
      layer.lineCap = .round
      layer.strokeStart = 0.0
    }

    trackLayer.strokeEnd = 1.0
    progressLayer.strokeEnd = 0.0
    indicatorLayer.strokeEnd = 1.0
  }

  private func createRing() -> NSBezierPath {
    let ring = NSBezierPath()
    var points = [CGPoint]()
    for theta in 0...270 {
      let x = radius * cos(CGFloat(theta) * .pi / 180.0)
      let y = radius * sin(CGFloat(theta) * .pi / 180.0)
      points.append(CGPoint(x: x, y: y))
    }

    ring.appendPoints(&points, count: points.count)
    ring.apply(.init(translationX: bounds.width / 2, y: bounds.height / 2)
      .rotated(by: CGFloat.pi / 180.0 * (90 + 45)))
    return ring
  }

  private func createIndicator() {
    let indicator = NSBezierPath()
    indicator.move(to: CGPoint(x: radius, y: 0.0))
    indicator.line(to: CGPoint(x: radius * (1.0 - indicatorLineLength), y: 0.0))
    indicator.apply(.init(translationX: bounds.width / 2, y: bounds.height / 2)
      .rotated(by: angleForNormalizedValue))
    indicatorLayer.path = indicator.cgPath
  }

  private func createTicks() {
    let ticks = NSBezierPath()
    let span = radius - trackLineWidth / 2.0
    for tickIndex in 0..<tickCount {
      let tick = NSBezierPath()
      let theta = angle(for: Float(tickIndex) / max(1.0, Float(tickCount - 1)))
      tick.move(to: CGPoint(x: 0.0 + span * (1.0 - tickLineOffset), y: 0.0))
      tick.line(to: CGPoint(x: 0.0 + span * (1.0 - tickLineLength), y: 0.0))
      tick.apply(.init(rotationAngle: theta))
      ticks.append(tick)
    }
    ticks.apply(CGAffineTransform(translationX: bounds.width / 2, y: bounds.height / 2))
    ticksLayer.path = ticks.cgPath
  }
}

#endif
