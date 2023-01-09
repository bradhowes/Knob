import XCTest

class KnobDemoUITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
    XCUIApplication().launchArguments += ["-AppleLanguages", "(en)"]
    XCUIApplication().launchArguments += ["-AppleLocale", "en_EN"]
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testSwipingUp() throws {
#if os(iOS) && !targetEnvironment(macCatalyst)
    let app = XCUIApplication()
    app.launch()

    let knob = app.otherElements["volume knob"]
    let label = app.staticTexts["volume label"]
    XCTAssertTrue(knob.waitForExistence(timeout: 5))

    knob.swipeUp()
    XCTAssertTrue(Double(label.label)! > 50.0)
#else
    throw XCTSkip("only runs on iOS")
#endif
  }

  func testSwipingDown() throws {
#if os(iOS) && !targetEnvironment(macCatalyst)
    let app = XCUIApplication()
    app.launch()

    let knob = app.otherElements["volume knob"]
    let label = app.staticTexts["volume label"]
    XCTAssertTrue(knob.waitForExistence(timeout: 5))

    knob.swipeDown()
    XCTAssertTrue(Double(label.label)! < 0.1)
#else
    throw XCTSkip("only runs on iOS")
#endif
  }

  func testTrackingUp() throws {
#if os(macOS)
    let app = XCUIApplication()
    app.launch()
    print(app.debugDescription)

    let knob = app.sliders["volume knob"]
    XCTAssertTrue(knob.waitForExistence(timeout: 5))

    let label = app.staticTexts["volume label"]
    XCTAssertTrue(label.waitForExistence(timeout: 5))

    let posA = knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    let posB = knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.0))
    posA.press(forDuration: 0.1, thenDragTo: posB)

    print("value: \(label.debugDescription)")
    print("value.label: \(label.label.debugDescription)")
    print("value.value: \(label.value.debugDescription)")

    XCTAssertTrue(Double(label.value as! String)! >= 70.0)
#else
    throw XCTSkip("only runs on macOS")
#endif
  }

  func testTrackingDown() throws {
#if os(macOS)
    let app = XCUIApplication()
    app.launch()

    let knob = app.sliders["volume knob"]
    XCTAssertTrue(knob.waitForExistence(timeout: 5))

    let label = app.staticTexts["volume label"]
    XCTAssertTrue(label.waitForExistence(timeout: 5))

    let posA = knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    let posB = knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
    posA.press(forDuration: 0.1, thenDragTo: posB)

    print("value: \(label.debugDescription)")
    print("value.label: \(label.label.debugDescription)")
    print("value.value: \(label.value.debugDescription)")

    XCTAssertTrue(Double(label.value as! String)! < 0.1)
#else
    throw XCTSkip("only runs on macOS")
#endif
  }
}
