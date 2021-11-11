// Copyright © 2018 Brad Howes. All rights reserved.

#if os(iOS) || os(tvOS)
import UIKit
public typealias KnobParentClass = UIControl
#elseif os(macOS)
import AppKit
public typealias KnobParentClass = NSControl
#endif

/**
 Custom UIControl/NSControl that depicts a value as a point on a circle. Changing the value is done by touching on the
 control and moving up to increase and down to decrease the current value. While touching, moving away from the control
 in either direction will increase the resolution of the touch changes, causing the value to change more slowly as
 vertical distance changes. Pretty much works like UISlider but with the travel path as an arc.

 Visual representation of the knob is done via CoreAnimation components, namely CAShapeLayer and UIBezierPath. The
 diameter of the arc of the knob is defined by the min(width, height) of the view's frame. The start and end of the arc
 is controlled by the `startAngle` and `endAngle` settings.
 */
open class Knob: KnobParentClass {

#if os(iOS) || os(tvOS)
  public typealias Color = UIColor
  public typealias BezierPath = UIBezierPath
  public typealias Label = UILabel
#elseif os(macOS)
  public typealias Color = NSColor
  public typealias BezierPath = NSBezierPath
  public typealias Label = NSText
#endif

  /// The minimum value reported by the control.
  public var minimumValue: Float = 0.0 { didSet { setValue(_value, animated: false) } }

  /// The maximum value reported by the control.
  public var maximumValue: Float = 1.0 { didSet { setValue(_value, animated: false) } }

  /// The current value of the control.
  @objc
  public dynamic var value: Float { get { _value } set { setValue(newValue, animated: false) } }

  /// How much travel is need to move 4x the width or height of the knob to go from minimumValue to maximumValue.
  /// By default this is 1x the knob size.
  public var touchSensitivity: Float = 1.0

  /// The width of the arc that is shown after the current value.
  public var trackLineWidth: CGFloat = 6 { didSet { trackLayer.lineWidth = trackLineWidth } }

  /// The color of the arc shown after the current value.
  public var trackColor: Color = Color.darkGray.darker.darker.darker
  { didSet { trackLayer.strokeColor = trackColor.cgColor } }

  /// The width of the arc from the start up to the current value.
  public var progressLineWidth: CGFloat = 4
  { didSet { progressLayer.lineWidth = progressLineWidth } }

  /// The color of the arc from the start up to the current value.
  public var progressColor: Color = Color(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
  { didSet { progressLayer.strokeColor = progressColor.cgColor } }

  /// The width of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorLineWidth: CGFloat = 2
  { didSet { indicatorLayer.lineWidth = indicatorLineWidth } }

  /// The color of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorColor: Color = Color(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
  { didSet { indicatorLayer.strokeColor = indicatorColor.cgColor } }

  /// The proportion of the radial line drawn from the current value on the arc towards the arc center.
  /// Range is from 0.0 to 1.0, where 1.0 will draw a complete line, and anything less will draw that fraction of it
  /// starting from the arc.
  public var indicatorLineLength: CGFloat = 0.3 { didSet { createShapes() } }

  /// Number of ticks to show inside the track, with the first indicating the `minimumValue` and the last indicating
  /// the `maximumValue`
  public var tickCount: Int = 0 { didSet { createShapes() } }

  public var tickLineOffset: CGFloat = 0.1 { didSet { createShapes() } }

  /// Length of the tick. Range is from 0.0 to 1.0 where 1.0 will draw a line ending at the center of the knob.
  public var tickLineLength: CGFloat = 0.2 { didSet { createShapes() } }

  /// The width of the tick line.
  public var tickLineWidth: CGFloat = 1.0 { didSet { ticksLayer.lineWidth = tickLineWidth } }

  /// The color of the tick line.
  public var tickColor: Color = .black { didSet { ticksLayer.strokeColor = tickColor.cgColor } }

  public var valueLabel: Label?
  public var valueName: String?
  public var valueFormatter: NumberFormatter?
  public var formattedValue: String { valueFormatter?.string(from: .init(value: _value)) ?? "\(_value)" }
  public var valuePersistence: TimeInterval = 1.0
  public var nameTransitionDuration = 0.5

  public private(set) var manipulating = false

  /**
   The starting angle of the arc where a value of 0.0 is located. Arc angles are explained in the UIBezier
   documentation for init(arcCenter:radius:startAngle:endAngle:clockwise:). In short, a value of 0.0 will start on
   the positive X axis, a positive PI/2 will lie on the negative Y axis. The default values will leave a 90° gap at
   the bottom.
   */
  private let startAngle: CGFloat = -CGFloat.pi / 180.0 * 225.0

  /// The ending angle of the arc where a value of 1.0 is located. See `startAngle` for additional info.
  private let endAngle: CGFloat = CGFloat.pi / 180.0 * 45.0

  private let trackLayer = CAShapeLayer()
  private let progressLayer = CAShapeLayer()
  private let indicatorLayer = CAShapeLayer()
  private let ticksLayer = CAShapeLayer()
  private let updateQueue = DispatchQueue(label: "KnobUpdates", qos: .userInteractive, attributes: [],
                                          autoreleaseFrequency: .inherit, target: .main)

  private var _value: Float = 0.0
  private var panOrigin: CGPoint = .zero
  private var restorationTimer: Timer?

#if os(macOS)
  override public var acceptsFirstResponder: Bool { get { return true } }
  var backingLayer: CALayer { layer! }
  override public var wantsUpdateLayer: Bool { true }
  override public var isFlipped: Bool { true }
#endif

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
}

// MARK: - Setting Value

extension Knob {

  /**
   Set the value of the knob.

   - parameter value: the new value to use
   - parameter animated: true if animating the change to the new value
   */
  public func setValue(_ value: Float, animated: Bool = false) {
    _value = clampedValue(value)
    draw(animated: animated)
#if os(macOS)
    updateLayer()
#endif
    restorationTimer?.invalidate()
#if os(macOS)
    valueLabel?.string = formattedValue
#elseif os(iOS) || os(tvOS)
    valueLabel?.text = formattedValue
#endif
  }
}

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
#if os(macOS)
      NSAnimationContext.runAnimationGroup({ context in
        context.duration = 1
        valueLabel.animator().string = valueName
      }) {
        valueLabel.animator().string = valueName
      }
#elseif os(iOS) || os(tvOS)
      UIView.transition(with: valueLabel, duration: self.nameTransitionDuration,
                        options: [.curveLinear, .transitionCrossDissolve]) {
        valueLabel.text = valueName
      } completion: { _ in
        valueLabel.text = valueName
      }
#endif
    }
  }
}

// MARK: - Layout

extension Knob {

  /**
   Reposition layers to reflect new size.
   */
#if os(macOS)
  public override func layout() {
    super.layout()
    doLayoutSubviews()
  }
#elseif os(iOS) || os(tvOS)
  public override func layoutSubviews() {
    super.layoutSubviews()
    doLayoutSubviews()
  }
#endif

  private func doLayoutSubviews() {

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

#if os(macOS)

  override public func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    return true
  }

  override open func mouseDown(with event: NSEvent) {
    panOrigin = event.locationInWindow
    manipulating = true
    notifyTarget()
  }

  override open func mouseDragged(with event: NSEvent) {
    guard manipulating == true else { return }
    updateValue(with: event.locationInWindow)
  }

  override open func mouseUp(with event: NSEvent) {
    manipulating = false
    restoreLabelWithName()
  }

#elseif os(iOS) || os(tvOS)

  override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    panOrigin = touch.location(in: self)
    manipulating = true
    notifyTarget()
    return true
  }

  override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    updateValue(with: touch.location(in: self))
    return true
  }

  override open func cancelTracking(with event: UIEvent?) {
    manipulating = false
    super.cancelTracking(with: event)
    restoreLabelWithName()
  }

  override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    manipulating = false
    super.endTracking(touch, with: event)
    restoreLabelWithName()
  }

#endif
}

#if os(macOS)
extension Knob : NSAccessibilitySlider {
  public override func isAccessibilityElement() -> Bool { true }
  public override func isAccessibilityEnabled() -> Bool { true }
}
#endif

// MARK: - Private

extension Knob {

  private func updateValue(with point: CGPoint) {
    // Scale Y changes by how far away in the X direction the touch is -- farther away the more one must travel in Y
    // to achieve the same change in value. Use `touchSensitivity` to increase/reduce this effect.
    let scaleT = 1 / (1.0 + log10(max(abs(Float(panOrigin.x - point.x) / 10.0), 1.0)))
#if os(macOS)
    let deltaT = Float(point.y - panOrigin.y) / (Float(min(bounds.height, bounds.width))) * touchSensitivity * scaleT
#elseif os(iOS) || os(tvOS)
    let deltaT = Float(panOrigin.y - point.y) / (Float(min(bounds.height, bounds.width))) * touchSensitivity * scaleT
#endif
    defer { panOrigin = CGPoint(x: panOrigin.x, y: point.y) }
    let change = deltaT * (maximumValue - minimumValue)
    self.value += change
    notifyTarget()
  }

  private func notifyTarget() {
#if os(macOS)
    updateQueue.async { self.sendAction(self.action, to: self.target) }
#elseif os(iOS) || os(tvOS)
    updateQueue.async { self.sendActions(for: .valueChanged) }
#endif
  }
}

extension Knob {

  private func initialize() {
#if os(macOS)
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
#elseif os(iOS) || os(tvOS)
    layer.addSublayer(ticksLayer)
    layer.addSublayer(trackLayer)
    layer.addSublayer(progressLayer)
    layer.addSublayer(indicatorLayer)
#endif

    trackLayer.fillColor = Color.clear.cgColor
    progressLayer.fillColor = Color.clear.cgColor
    indicatorLayer.fillColor = Color.clear.cgColor
    ticksLayer.fillColor = Color.clear.cgColor

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

  private func createShapes() {
    createTrack()
    createIndicator()
    createTicks()
    createProgressTrack()

    draw(animated: false)
  }

  private func createRing() -> BezierPath {
#if os(macOS)
    let ring = BezierPath()
    var points = [CGPoint]()
    for theta in 0...270 {
      let x = radius * cos(CGFloat(theta) * .pi / 180.0)
      let y = radius * sin(CGFloat(theta) * .pi / 180.0)
      points.append(CGPoint(x: x, y: y))
    }

    ring.appendPoints(&points, count: points.count)
    ring.apply(CGAffineTransform(rotationAngle: CGFloat.pi / 180.0 * (90 + 45)))
#elseif os(iOS) || os(tvOS)
    let ring = UIBezierPath(arcCenter: CGPoint.zero, radius: radius, startAngle: startAngle, endAngle: endAngle,
                            clockwise: true)
#endif

    return ring
  }

  private func createTrack() {
    let ring = createRing()
    trackLayer.path = ring.cgPath

  }

  private func createIndicator() {
    let indicator = BezierPath()
    indicator.move(to: CGPoint(x: radius, y: 0.0))
#if os(macOS)
    indicator.line(to: CGPoint(x: radius * (1.0 - indicatorLineLength), y: 0.0))
#elseif os(iOS) || os(tvOS)
    indicator.addLine(to: CGPoint(x: radius * (1.0 - indicatorLineLength), y: 0.0))
#endif
    indicatorLayer.path = indicator.cgPath
  }

  private func createProgressTrack() {
    let progressRing = createRing()
    progressLayer.path = progressRing.cgPath
  }

  private func createTicks() {
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

  private func draw(animated: Bool = false) {
    if manipulating || !animated { CATransaction.setDisableActions(true) }
#if os(macOS)
    progressLayer.removeAllAnimations()
    indicatorLayer.removeAllAnimations()
#endif
    progressLayer.strokeEnd = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
    indicatorLayer.transform = CATransform3DMakeRotation(angleForValue, 0, 0, 1)
  }

  private var radius: CGFloat { (min(trackLayer.bounds.width, trackLayer.bounds.height) / 2) - trackLineWidth }

  private var angleForValue: CGFloat { angle(for: (self.value - minimumValue) / (maximumValue - minimumValue)) }

  private func angle(for normalizedValue: Float) -> CGFloat {
    CGFloat(normalizedValue) * (endAngle - startAngle) + startAngle
  }

  private func clampedValue(_ value: Float) -> Float { min(maximumValue, max(minimumValue, value)) }
}
