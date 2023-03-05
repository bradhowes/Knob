import XCTest
import SnapshotTesting
@testable import Knob_macOS

#if os(macOS)

final class KnobTests: XCTestCase {

  var knob: Knob!

  override func setUp() {
    super.setUp()
    isRecording = false
    self.knob = .init(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.minimumValue = 0.0
    knob.maximumValue = 1.0
    knob.trackColor = .black
    knob.progressColor = .red
    knob.indicatorColor = .red
    knob.tickColor = .black
    knob.tickLineWidth = 2.0
    knob.backgroundColor = .white
  }

  func makeName(_ funcName: String) -> String { funcName + "-" + "macOS" }

  func assertSnapshot(file: StaticString = #file, testName: String = #function, line: UInt = #line) throws {
    knob.layoutSubtreeIfNeeded()
    knob.display()
    let scaling = NSScreen.main?.backingScaleFactor ?? 1
    let failure = verifySnapshot(matching: knob,
                                 as: .image(precision: 1.0, perceptualPrecision: 1.0),
                                 named: "\(scaling)",
                                 record: isRecording,
                                 snapshotDirectory: nil,
                                 file: file,
                                 testName: testName,
                                 line: line)
    guard let message = failure else { return }
    XCTFail(message, file: file, line: line)
  }

  func testValueClamping() {
    knob.value = 0.5
    XCTAssertEqual(knob.value, 0.5)

    knob.value = -1.0
    XCTAssertEqual(knob.value, 0.0)

    knob.value = 2.0
    XCTAssertEqual(knob.value, 1.0)

    knob.value = 0.0
    knob.minimumValue = 0.3
    XCTAssertEqual(knob.value, 0.3)

    knob.value = 1.0
    knob.maximumValue = 0.6
    XCTAssertEqual(knob.value, 0.6)

    knob.minimumValue = 1.0
    XCTAssertEqual(knob.maximumValue, 2.0)
    XCTAssertEqual(knob.value, 1.0)

    knob.maximumValue = 1.0
    XCTAssertEqual(knob.minimumValue, 0.0)
    XCTAssertEqual(knob.value, 1.0)
  }

  func testDefault() throws {
    knob.value = 0.5
    try assertSnapshot()
  }

  func testTrackLineWidth() throws {
    knob.trackWidthFactor = 0.09
    knob.value = 0.5
    try assertSnapshot()
  }

  func testTrackColor() throws {
    knob.trackColor = .green
    knob.value = 0.5
    try assertSnapshot()
  }

  func testProgressLineWidth() throws {
    knob.progressWidthFactor = 0.1
    knob.value = 0.5
    try assertSnapshot()
  }

  func testProgressColor() throws {
    knob.progressColor = .green
    knob.value = 0.5
    try assertSnapshot()
  }

  func testIndicatorLineWidth() throws {
    knob.indicatorWidthFactor = 0.1
    knob.value = 0.5
    try assertSnapshot()
  }

  func testIndicatorColor() throws {
    knob.indicatorColor = .green
    knob.value = 0.5
    try assertSnapshot()
  }

  func testIndicatorLineLength() throws {
    knob.indicatorLineLength = 0.5
    knob.value = 0.5
    try assertSnapshot()
  }

  func testTickCount() throws {
    knob.tickCount = 5
    knob.value = 0.3
    try assertSnapshot()
  }

  func testTickLineWidth() throws {
    knob.tickCount = 5
    knob.tickLineWidth = 12.0
    knob.value = 0.3
    try assertSnapshot()
  }

  func testTickColor() throws {
    knob.tickCount = 5
    knob.tickColor = .red
    knob.value = 0.3
    try assertSnapshot()
  }

  func testTickLineLength() throws {
    knob.tickCount = 5
    knob.tickLineLength = 0.5
    knob.value = 0.3
    try assertSnapshot()
  }

  func testTickLineOffset() throws {
    knob.tickCount = 5
    knob.tickLineOffset = 0.5
    knob.value = 0.3
    try assertSnapshot()
  }

  func testFormattedValue() throws {
    knob.value = 0.3
    XCTAssertEqual(knob.formattedValue, "0.3")
    let valueFormatter = NumberFormatter()
    valueFormatter.minimumFractionDigits = 6
    knob.valueFormatter = valueFormatter
    XCTAssertEqual(knob.formattedValue, "0.300000")
  }

  func testStartAngle() throws {
    knob.startAngle = -CGFloat.pi / 180.0 * 220.0
    try assertSnapshot()
  }

  func testEndAngle() throws {
    knob.endAngle = -CGFloat.pi / 180.0 * 240.0
    try assertSnapshot()
  }

  func testTagging() throws {
    knob.tag = 12345
    XCTAssertEqual(knob.tag, 12345)
  }

  func testSetValue() throws {
    knob.setValue(0.5)
    XCTAssertEqual(knob.value, 0.5)
    try assertSnapshot()
  }

  func testNonNormalUserRange() throws {
    knob.minimumValue = -50.0
    knob.maximumValue = 10.0
    knob.setValue(-20.0)
    try assertSnapshot()
  }

  func testManipulatingState() throws {
    XCTAssertFalse(knob.manipulating)
    knob.move(to: CGPoint(x: 50.0, y: 50.0))
    XCTAssertFalse(knob.manipulating)
    knob.beginMove(with: CGPoint(x: 50.0, y: 50.0))
    XCTAssertTrue(knob.manipulating)
    knob.move(to: CGPoint(x: 50.0, y: 55.0))
    XCTAssertTrue(knob.manipulating)
    knob.move(to: CGPoint(x: 50.0, y: 60.0))
    XCTAssertTrue(knob.manipulating)
    knob.endMove()
    XCTAssertFalse(knob.manipulating)
  }

  func testMovementDown() throws {
    knob.minimumValue = -50.0
    knob.maximumValue = 10.0
    knob.setValue(-20.0)

    knob.beginMove(with: CGPoint(x: 50.0, y: 50.0))
    knob.move(to: CGPoint(x: 50.0, y: 80.0))
    knob.endMove()

    XCTAssertEqual(knob.value, -38.0)

    try assertSnapshot()
  }

  func testMovementUp() throws {
    knob.minimumValue = -50.0
    knob.maximumValue = 10.0
    knob.setValue(-20.0)

    knob.beginMove(with: CGPoint(x: 50.0, y: 50.0))
    knob.move(to: CGPoint(x: 50.0, y: 30.0))
    knob.endMove()

    XCTAssertEqual(knob.value, -8.0)

    try assertSnapshot()
  }

  func testSlowMovementUp() throws {
    knob.minimumValue = -50.0
    knob.maximumValue = 10.0
    knob.setValue(-20.0)

    knob.beginMove(with: CGPoint(x: 50.0, y: 50.0))
    knob.move(to: CGPoint(x: 150.0, y: 30.0))
    knob.move(to: CGPoint(x: 150.0, y: 30.0))
    knob.endMove()

    XCTAssertEqual(knob.value, -19.76)

    try assertSnapshot()
  }

  func testBackgroundColor() throws {
    knob.backgroundColor = .green
    XCTAssertEqual(knob.backgroundColor, .green)
  }

  func testAcceptsFirstReponder() {
    XCTAssertTrue(knob.acceptsFirstResponder)
  }

  func testAcceptsFirstMouse() {
    XCTAssertTrue(knob.acceptsFirstMouse(for: .none))
  }

  func testAccessibilityTraits() {
    XCTAssertTrue(knob.isAccessibilityElement())
    XCTAssertTrue(knob.isAccessibilityEnabled())
  }
}

#endif
