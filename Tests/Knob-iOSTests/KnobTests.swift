import XCTest
import SnapshotTesting
@testable import Knob_iOS

#if os(iOS)

final class KnobTests: XCTestCase {

  var knob: Knob!

  override func setUp() {
    super.setUp()
    isRecording = false
    self.knob = .init(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.minimumValue = 0.0
    knob.maximumValue = 1.0
    knob.backgroundColor = .black
    knob.trackColor = .white
    knob.progressColor = .red
    knob.indicatorColor = .red
    knob.tickColor = .white
    knob.tickLineWidth = 1.0
  }

  func makeName(_ funcName: String) -> String {
    let platform: String
    platform = "iOS"
    return funcName + "-" + platform
  }

  func assertSnapshot(matching: Knob, file: StaticString = #file, testName: String = #function, line: UInt = #line) throws {
    // try XCTSkipIf(ProcessInfo.processInfo.environment.keys.contains("GITHUB_WORKFLOW"), "GitHub CI")
    SnapshotTesting.assertSnapshot(matching: matching, as: .image, named: makeName(testName), file: file, testName: testName, line: line)
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
  }

  func testDefault() throws {
    knob.value = 0.4
    try assertSnapshot(matching: knob)
  }

  func testTrackLineWidth() throws {
    knob.trackWidthFactor = 0.07
    knob.trackColor = .black
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testTrackColor() throws {
    knob.trackColor = .systemTeal
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testProgressLineWidth() throws {
    knob.progressWidthFactor = 0.6
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testProgressColor() throws {
    knob.progressColor = .systemTeal
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testIndicatorLineWidth() throws {
    knob.indicatorWidthFactor = 0.04
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testIndicatorColor() throws {
    knob.indicatorColor = .systemTeal
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testIndicatorLineLength() throws {
    knob.indicatorLineLength = 1.0
    knob.value = 0.5
    try assertSnapshot(matching: knob)
  }

  func testTickCount() throws {
    knob.tickCount = 5
    knob.value = 0.3
    try assertSnapshot(matching: knob)
  }

  func testTickLineWidth() throws {
    knob.tickCount = 5
    knob.tickLineWidth = 12.0
    knob.tickColor = .systemTeal
    knob.value = 0.3
    try assertSnapshot(matching: knob)
  }

  func testTickColor() throws {
    knob.tickCount = 5
    knob.tickColor = .systemTeal
    knob.value = 0.3
    try assertSnapshot(matching: knob)
  }

  func testTickLineLength() throws {
    knob.tickCount = 5
    knob.tickLineLength = 0.5
    knob.tickColor = .systemTeal
    knob.value = 0.3
    try assertSnapshot(matching: knob)
  }

  func testTickLineOffset() throws {
    knob.tickCount = 5
    knob.tickLineOffset = 0.5
    knob.tickColor = .systemTeal
    knob.value = 0.3
    try assertSnapshot(matching: knob)
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
    try assertSnapshot(matching: knob)
  }

  func testEndAngle() throws {
    knob.endAngle = -CGFloat.pi / 180.0 * 240.0
    try assertSnapshot(matching: knob)
  }

  func testTagging() throws {
    knob.tag = 12345
    XCTAssertEqual(knob.tag, 12345)
  }

  func testSetValue() throws {
    knob.setValue(0.5)
    XCTAssertEqual(knob.value, 0.5)
    try assertSnapshot(matching: knob)
  }

  func testNonNormalUserRange() throws {
    knob.minimumValue = -50.0
    knob.maximumValue = 10.0
    knob.setValue(-20.0)
    try assertSnapshot(matching: knob)
  }
}

#endif
