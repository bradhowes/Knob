import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Knob_iOSTests.allTests),
    ]
}
#endif
