import XCTest
import SnapshotTesting
@testable import Knob_macOS

#if os(macOS)

final class KnobTests: XCTestCase {

  override func setUp() {
    isRecording = false
    super.setUp()
  }

  func makeName(_ funcName: String) -> String {
    let platform: String
    platform = "macOS"
    return funcName + "-" + platform
  }

  func assertSnapshot(matching: Knob, file: StaticString = #file, testName: String = #function, line: UInt = #line) throws {
    let env = ProcessInfo.processInfo.environment

    for key in env.keys {
      print("\(key) = \(env[key]!)")
    }

    try XCTSkipIf(ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW"), "GitHub CI")
    SnapshotTesting.assertSnapshot(matching: matching, as: .image, named: makeName(testName), file: file, testName: testName, line: line)
  }

  func testValueClamping() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))

    knob.minimumValue = 0.0
    knob.maximumValue = 1.0

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
  }

  func testDefault() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testTrackLineWidth() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.trackWidthFactor = 0.09
    knob.trackColor = .black
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testTrackColor() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.trackColor = .systemTeal
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testProgressLineWidth() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.progressWidthFactor = 0.07
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testProgressColor() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.progressColor = .systemTeal
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testIndicatorLineWidth() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.indicatorWidthFactor = 0.06
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testIndicatorColor() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.indicatorColor = .systemTeal
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testIndicatorLineLength() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.indicatorLineLength = 1.0
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testTickCount() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.tickCount = 5
    knob.value = 0.3
    try assertSnapshot(matching: knob)
  }

  func testTickLineWidth() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.tickCount = 5
    knob.tickLineWidth = 12.0
    knob.tickColor = .systemTeal
    knob.value = 0.3
    try assertSnapshot(matching: knob)
  }

  func testTickColor() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.tickCount = 5
    knob.tickColor = .systemTeal
    knob.value = 0.3
    try assertSnapshot(matching: knob)
  }

  func testTickLineLength() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.tickCount = 5
    knob.tickLineLength = 0.5
    knob.tickColor = .systemTeal
    knob.value = 0.3
    try assertSnapshot(matching: knob)
  }

  func testTickLineOffset() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.tickCount = 5
    knob.tickLineOffset = 0.5
    knob.tickColor = .systemTeal
    knob.value = 0.3
    try assertSnapshot(matching: knob)
  }

  func testFormattedValue() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.value = 0.3
    XCTAssertEqual(knob.formattedValue, "0.3")
    let valueFormatter = NumberFormatter()
    valueFormatter.minimumFractionDigits = 6
    knob.valueFormatter = valueFormatter
    XCTAssertEqual(knob.formattedValue, "0.300000")
  }

  func testStartAngle() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.startAngle = -CGFloat.pi / 180.0 * 220.0
    try assertSnapshot(matching: knob)
  }

  func testEndAngle() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.endAngle = -CGFloat.pi / 180.0 * 240.0
    try assertSnapshot(matching: knob)
  }

  func testTagging() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.tag = 12345
    XCTAssertEqual(knob.tag, 12345)
  }

  func testSetValue() throws {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.setValue(0.5)
    XCTAssertEqual(knob.value, 0.5)
    try assertSnapshot(matching: knob)
  }

  func testNonNormalUserRange() throws {
    // isRecording = true
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.minimumValue = -50.0
    knob.maximumValue = 10.0
    knob.setValue(-20.0)
    try assertSnapshot(matching: knob)
  }
}

#endif
