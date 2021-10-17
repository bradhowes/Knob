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

    let knob = app.otherElements["knob"]
    let value = app.staticTexts["value"]
    XCTAssertTrue(value.waitForExistence(timeout: 5))

    // print(value.debugDescription)
    knob.swipeUp()
    XCTAssertTrue(Double(value.label)! > 0.825)
#else
    throw XCTSkip("only runs on iOS")
#endif
  }

  func testSwipingDown() throws {
#if os(iOS) && !targetEnvironment(macCatalyst)
    let app = XCUIApplication()
    app.launch()

    let knob = app.otherElements["knob"]
    let value = app.staticTexts["value"]
    XCTAssertTrue(value.waitForExistence(timeout: 5))

    // print(value.debugDescription)
    knob.swipeDown()
    XCTAssertTrue(Double(value.label)! < 0.1)
#else
    throw XCTSkip("only runs on iOS")
#endif
  }

  func testTrackingUp() throws {
#if os(macOS)
    let app = XCUIApplication()
    app.launch()
    print(app.debugDescription)
    
    let knob = app.sliders["knob"]
    XCTAssertTrue(knob.waitForExistence(timeout: 5))

    let value = app.staticTexts["value"]
    XCTAssertTrue(value.waitForExistence(timeout: 5))

    let posA = knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
    let posB = knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.0))
    posA.press(forDuration: 0.1, thenDragTo: posB)

    print("value: \(value.debugDescription)")
    print("value.label: \(value.label.debugDescription)")
    print("value.value: \(value.value.debugDescription)")

    XCTAssertTrue(Double(app.staticTexts["value"].value as! String)! >= 0.825)
#else
    throw XCTSkip("only runs on macOS")
#endif
  }

  func testTrackingDown() throws {
#if os(macOS)
    let app = XCUIApplication()
    app.launch()

    let knob = app.sliders["knob"]
    XCTAssertTrue(knob.waitForExistence(timeout: 5))

    let value = app.staticTexts["value"]
    XCTAssertTrue(value.waitForExistence(timeout: 5))

    let posA = knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
    let posB = knob.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
    posA.press(forDuration: 0.1, thenDragTo: posB)

    print("value: \(value.debugDescription)")
    print("value.label: \(value.label.debugDescription)")
    print("value.value: \(value.value.debugDescription)")

    XCTAssertTrue(Double(app.staticTexts["value"].value as! String)! < 0.1)
#else
    throw XCTSkip("only runs on macOS")
#endif
  }
}
