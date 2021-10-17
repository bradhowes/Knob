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
#if os(macOS) || targetEnvironment(macCatalyst)
    let app = XCUIApplication()
    app.launch()

    let title = app.staticTexts["title"]
    let knob = app.otherElements["knob"]
    let value = app.staticTexts["value"]
    XCTAssertTrue(value.waitForExistence(timeout: 5))

    knob.click(forDuration: 0.2, thenDragTo: title)
    print("value: \(value.debugDescription)")
    print("value.label: \(value.label.debugDescription)")
    XCTAssertTrue(Double(app.staticTexts["value"].label)! >= 0.825)
#else
    throw XCTSkip("only runs on iOS")
#endif
  }

  func testTrackingDown() throws {
#if os(macOS) || targetEnvironment(macCatalyst)
    let app = XCUIApplication()
    app.launch()

    let knob = app.otherElements["knob"]
    let value = app.staticTexts["value"]
    XCTAssertTrue(value.waitForExistence(timeout: 5))

    knob.click(forDuration: 0.2, thenDragTo: value)
    print("value: \(value.debugDescription)")
    print("value.label: \(value.label.debugDescription)")
    XCTAssertTrue(Double(app.staticTexts["value"].label)! < 0.1)
#else
    throw XCTSkip("only runs on iOS")
#endif
  }
}
