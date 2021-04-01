import XCTest

#if !canImport(ObjectiveC)

extension Entita2Tests {
    static let __allTests__Entita2Tests = [
        ("testFormats", testFormats),
        ("testGetID", testGetID),
        ("testIDBytes", testIDBytes),
        ("testUUIDID", testUUIDID),
        ("testEntityName", testEntityName),
        ("testGetPackedSelf", testGetPackedSelf),
        ("testLoad", asyncTest(testLoad)),
        ("testSave", asyncTest(testSave)),
        ("testInsert", asyncTest(testInsert)),
        ("testDelete", asyncTest(testDelete)),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    [
        testCase(Entita2Tests.__allTests__Entita2Tests),
    ]
}

#endif
