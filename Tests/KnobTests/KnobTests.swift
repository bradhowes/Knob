import XCTest
@testable import Knob

final class KnobTests: XCTestCase {

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

    static var allTests = [
        ("testExample", testValueClamping),
    ]
}
