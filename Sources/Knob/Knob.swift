// Copyright © 2018 Brad Howes. All rights reserved.

#if os(iOS)

import UIKit

/**
 Custom UIControl that depicts a value as a point on a circle. Changing the value is done by touching on the
 control and moving up to increase and down to decrease the current value. While touching, moving away from the control
 in either direction will increase the resolution of the touch changes, causing the value to change more slowly as
 vertical distance changes. Pretty much works like UISlider but with the travel path as an arc.

 Visual representation of the knob is done via CoreAnimation components, namely CAShapeLayer and UIBezierPath. The
 diameter of the arc of the knob is defined by the min(width, height) of the view's frame. The start and end of the arc
 is controlled by the `startAngle` and `endAngle` settings.
 */
open class Knob: UIControl {

  public typealias KnobColor = UIColor
  public typealias BezierPath = UIBezierPath
  public typealias Label = UILabel

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
  public var trackColor: KnobColor = KnobColor.darkGray.darker.darker.darker
  { didSet { trackLayer.strokeColor = trackColor.cgColor } }

  /// The width of the arc from the start up to the current value.
  public var progressLineWidth: CGFloat = 4
  { didSet { progressLayer.lineWidth = progressLineWidth } }

  /// The color of the arc from the start up to the current value.
  public var progressColor: KnobColor = KnobColor(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
  { didSet { progressLayer.strokeColor = progressColor.cgColor } }

  /// The width of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorLineWidth: CGFloat = 2
  { didSet { indicatorLayer.lineWidth = indicatorLineWidth } }

  /// The color of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorColor: KnobColor = KnobColor(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
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
  public var tickColor: KnobColor = .black { didSet { ticksLayer.strokeColor = tickColor.cgColor } }

  /// The text element to use to show the knob's value and name.
  public var valueLabel: Label?

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
  public internal(set) var manipulating = false

  /**
   The starting angle of the arc where a value of 0.0 is located. Arc angles are explained in the UIBezier
   documentation for init(arcCenter:radius:startAngle:endAngle:clockwise:). In short, a value of 0.0 will start on
   the positive X axis, a positive PI/2 will lie on the negative Y axis. The default values will leave a 90° gap at
   the bottom.
   */
  public var startAngle: CGFloat = -CGFloat.pi / 180.0 * 225.0 { didSet { createShapes() } }

  /// The ending angle of the arc where a value of 1.0 is located. See `startAngle` for additional info.
  public var endAngle: CGFloat = CGFloat.pi / 180.0 * 45.0 { didSet { createShapes() } }

  internal let trackLayer = CAShapeLayer()
  internal let progressLayer = CAShapeLayer()
  internal let indicatorLayer = CAShapeLayer()
  internal let ticksLayer = CAShapeLayer()
  internal let updateQueue = DispatchQueue(label: "KnobUpdates", qos: .userInteractive, attributes: [],
                                          autoreleaseFrequency: .inherit, target: .main)

  internal var _value: Float = 0.0
  internal var panOrigin: CGPoint = .zero
  internal var restorationTimer: Timer?

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

#elseif os(macOS)

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

  public typealias KnobColor = NSColor
  public typealias BezierPath = NSBezierPath
  public typealias Label = NSText

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
  public var trackColor: KnobColor = KnobColor.darkGray.darker.darker.darker
  { didSet { trackLayer.strokeColor = trackColor.cgColor } }

  /// The width of the arc from the start up to the current value.
  public var progressLineWidth: CGFloat = 4
  { didSet { progressLayer.lineWidth = progressLineWidth } }

  /// The color of the arc from the start up to the current value.
  public var progressColor: KnobColor = KnobColor(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
  { didSet { progressLayer.strokeColor = progressColor.cgColor } }

  /// The width of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorLineWidth: CGFloat = 2
  { didSet { indicatorLayer.lineWidth = indicatorLineWidth } }

  /// The color of the radial line drawn from the current value on the arc towards the arc center.
  public var indicatorColor: KnobColor = KnobColor(red: 1.0, green: 0.575, blue: 0.0, alpha: 1.0)
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
  public var tickColor: KnobColor = .black { didSet { ticksLayer.strokeColor = tickColor.cgColor } }

  /// The text element to use to show the knob's value and name.
  public var valueLabel: Label?

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
  public internal(set) var manipulating = false

  /**
   The starting angle of the arc where a value of 0.0 is located. Arc angles are explained in the UIBezier
   documentation for init(arcCenter:radius:startAngle:endAngle:clockwise:). In short, a value of 0.0 will start on
   the positive X axis, a positive PI/2 will lie on the negative Y axis. The default values will leave a 90° gap at
   the bottom.
   */
  public var startAngle: CGFloat = -CGFloat.pi / 180.0 * 225.0 { didSet { createShapes() } }

  /// The ending angle of the arc where a value of 1.0 is located. See `startAngle` for additional info.
  public var endAngle: CGFloat = CGFloat.pi / 180.0 * 45.0 { didSet { createShapes() } }

  internal let trackLayer = CAShapeLayer()
  internal let progressLayer = CAShapeLayer()
  internal let indicatorLayer = CAShapeLayer()
  internal let ticksLayer = CAShapeLayer()
  internal let updateQueue = DispatchQueue(label: "KnobUpdates", qos: .userInteractive, attributes: [],
                                          autoreleaseFrequency: .inherit, target: .main)

  internal var _value: Float = 0.0
  internal var panOrigin: CGPoint = .zero
  internal var restorationTimer: Timer?

  override public var acceptsFirstResponder: Bool { get { return true } }
  var backingLayer: CALayer { layer! }
  override public var wantsUpdateLayer: Bool { true }
  override public var isFlipped: Bool { true }

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

#endif
