// Copyright © 2018 Brad Howes. All rights reserved.

#if os(iOS)

import UIKit

/**
 Custom UIControl/NSControl that depicts a value as a point on a circle. Changing the value is done by touching on the
 control and moving up to increase and down to decrease the current value. While touching, moving away from the control
 in either direction will increase the resolution of the touch changes, causing the value to change more slowly as
 vertical distance changes. Pretty much works like UISlider but with the travel path as an arc.

 Visual representation of the knob is done via CoreAnimation components, namely CAShapeLayer and UIBezierPath. The
 diameter of the arc of the knob is defined by the min(width, height) of the view's frame. The start and end of the arc
 is controlled by the `startAngle` and `endAngle` settings.
 */
open class Knob: UIControl {

  /// The minimum value reported by the control.
  public var minimumValue: Float = 0.0 { didSet { setValue(_value, animated: false) } }

  /// The maximum value reported by the control.
  public var maximumValue: Float = 1.0 { didSet { setValue(_value, animated: false) } }

  /// The current value of the control.
  @objc
  public dynamic var value: Float { get { _value } set { setValue(newValue, animated: false) } }

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

  /// The width of the arc that is shown after the current value.
  public var trackLineWidth: CGFloat = 6 { didSet { trackLayer.lineWidth = trackLineWidth } }

  /// The color of the arc shown after the current value.
  public var trackColor: UIColor = UIColor.darkGray.darker.darker.darker
  { didSet { trackLayer.strokeColor = trackColor.cgColor } }

  /// The width of the arc from the start up to the current value.
  public var progressLineWidth: CGFloat = 4
  { didSet { progressLayer.lineWidth = progressLineWidth } }

  /// The color of the arc from the start up to the current value.
  public var progressColor: UIColor = .init(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
  { didSet { progressLayer.strokeColor = progressColor.cgColor } }

  /// The width of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorLineWidth: CGFloat = 2
  { didSet { indicatorLayer.lineWidth = indicatorLineWidth } }

  /// The color of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorColor: UIColor = .init(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
  { didSet { indicatorLayer.strokeColor = indicatorColor.cgColor } }

  /// The proportion of the radial line drawn from the current value on the arc towards the arc center.
  /// Range is from 0.0 to 1.0, where 1.0 will draw a complete line, and anything less will draw that fraction of it
  /// starting from the arc.
  public var indicatorLineLength: CGFloat = 0.3 { didSet { createShapes() } }

  /// Number of ticks to show inside the track, with the first indicating the `minimumValue` and the last indicating
  /// the `maximumValue`
  public var tickCount: Int = 0 { didSet { createShapes() } }

  /// Offset for the start of a tick line. Range is from 0.0 to 1.0 where 0.0 starts at the circumference of the arc,
  /// and 0.5 is midway between the circumference and the center along a radial.
  public var tickLineOffset: CGFloat = 0.1 { didSet { createShapes() } }

  /// Length of the tick. Range is from 0.0 to 1.0 where 1.0 will draw a line ending at the center of the knob.
  public var tickLineLength: CGFloat = 0.2 { didSet { createShapes() } }

  /// The width of the tick line.
  public var tickLineWidth: CGFloat = 1.0 { didSet { ticksLayer.lineWidth = tickLineWidth } }

  /// The color of the tick line.
  public var tickColor: UIColor = .black { didSet { ticksLayer.strokeColor = tickColor.cgColor } }

  /// The text element to use to show the knob's value and name.
  public var valueLabel: UILabel?

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
  public var formattedValue: String { valueFormatter?.string(from: .init(value: _value)) ?? "\(_value)" }

  /// Obtain the manipulating state of the knob. This is `true` during a touch event or a mouse-down event, and it goes
  /// back to `false` once the event ends.
  public private(set) var manipulating = false

  /**
   The starting angle of the arc where a value of 0.0 is located. Arc angles are explained in the UIBezier
   documentation for init(arcCenter:radius:startAngle:endAngle:clockwise:). In short, a value of 0.0 will start on
   the positive X axis, a positive PI/2 will lie on the negative Y axis. The default values will leave a 90° gap at
   the bottom.
   */
  public var startAngle: CGFloat = -CGFloat.pi / 180.0 * 225.0 { didSet { createShapes() } }

  /// The ending angle of the arc where a value of 1.0 is located. See `startAngle` for additional info.
  public var endAngle: CGFloat = CGFloat.pi / 180.0 * 45.0 { didSet { createShapes() } }

  private let trackLayer = CAShapeLayer()
  private let progressLayer = CAShapeLayer()
  private let indicatorLayer = CAShapeLayer()
  private let ticksLayer = CAShapeLayer()
  private let updateQueue = DispatchQueue(label: "KnobUpdates", qos: .userInteractive, attributes: [],
                                          autoreleaseFrequency: .inherit, target: .main)

  private var _value: Float = 0.0
  private var panOrigin: CGPoint = .zero
  private var restorationTimer: Timer?

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
    restorationTimer?.invalidate()
    valueLabel?.text = formattedValue
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

  private func performRestoration(label: UILabel, value: String) {
      UIView.transition(with: label, duration: nameTransitionDuration,
                        options: [.curveLinear, .transitionCrossDissolve]) {
        label.text = value
      } completion: { _ in
        label.text = value
      }
  }
}

// MARK: - Layout

extension Knob {

  /**
   Reposition layers to reflect new size.
   */
  public override func layoutSubviews() {
    super.layoutSubviews()
    doLayoutSubviews()
  }

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
}

// MARK: - Private

extension Knob {

  private var maxChangeRegionWidthHalf: CGFloat { min(4, travelDistance * maxChangeRegionWidthPercentage) / 2 }
  private var halfTravelDistance: CGFloat { travelDistance / 2 }

  private func updateValue(with point: CGPoint) {
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

  private func notifyTarget() {
    updateQueue.async { self.sendActions(for: .valueChanged) }
  }
}

extension Knob {

  private func initialize() {
    layer.addSublayer(ticksLayer)
    layer.addSublayer(trackLayer)
    layer.addSublayer(progressLayer)
    layer.addSublayer(indicatorLayer)

    trackLayer.fillColor = UIColor.clear.cgColor
    progressLayer.fillColor = UIColor.clear.cgColor
    indicatorLayer.fillColor = UIColor.clear.cgColor
    ticksLayer.fillColor = UIColor.clear.cgColor

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

  private func createRing() -> UIBezierPath {
    .init(arcCenter: CGPoint.zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
  }

  private func createTrack() {
    let ring = createRing()
    trackLayer.path = ring.cgPath

  }

  private func createIndicator() {
    let indicator = UIBezierPath()
    indicator.move(to: CGPoint(x: radius, y: 0.0))
    indicator.addLine(to: CGPoint(x: radius * (1.0 - indicatorLineLength), y: 0.0))
    indicatorLayer.path = indicator.cgPath
  }

  private func createProgressTrack() {
    let progressRing = createRing()
    progressLayer.path = progressRing.cgPath
  }

  private func createTicks() {
    let ticks = UIBezierPath()
    for tickIndex in 0..<tickCount {
      let tick = UIBezierPath()
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

#endif
