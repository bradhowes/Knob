import XCTest
import SnapshotTesting
@testable import Knob

final class KnobTests: XCTestCase {

  override func setUp() {
    isRecording = false
    super.setUp()
  }

  func makeName(_ funcName: String = #function) -> String {
#if os(macOS)
    let platform = "macOS"
#elseif os(iOS)
    let platform = "iOS"
#elseif os(tvOS)
    let platform = "tvOS"
#else
    let platform = "unknown"
#endif
    return funcName + "-" + platform
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

  func testDefault() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.value = 0.5
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  func testTrackLineWidth() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.trackLineWidth = 12.0
    knob.trackColor = .black
    knob.value = 0.5
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  func testTrackColor() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.trackColor = .systemTeal
    knob.value = 0.5
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  func testProgressLineWidth() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.progressLineWidth = 12.0
    knob.value = 0.5
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  func testProgressColor() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.progressColor = .systemTeal
    knob.value = 0.5
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  func testIndicatorLineWidth() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.indicatorLineWidth = 12.0
    knob.value = 0.5
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  func testIndicatorColor() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.indicatorColor = .systemTeal
    knob.value = 0.5
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  func testIndicatorLineLength() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.indicatorLineLength = 1.0
    knob.value = 0.5
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  func testTickCount() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.tickCount = 5
    knob.value = 0.3
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  func testTickLineWidth() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.tickCount = 5
    knob.tickLineWidth = 12.0
    knob.tickColor = .systemTeal
    knob.value = 0.3
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  func testTickColor() {
    let knob = Knob(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    knob.tickCount = 5
    knob.tickColor = .systemTeal
    knob.value = 0.3
    assertSnapshot(matching: knob, as: .image, named: makeName())
  }

  static var allTests = [
    ("testExample", testValueClamping),
  ]
}
