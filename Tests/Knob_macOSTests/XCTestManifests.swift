import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Knob_macOSTests.allTests),
    ]
}
#endif
