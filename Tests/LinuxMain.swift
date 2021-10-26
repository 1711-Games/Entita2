import XCTest
import Entita2Tests

@main
public struct Main {
    public static func main() {
        var tests = [XCTestCaseEntry]()
        tests += Entita2Tests.__allTests()
        XCTMain(tests)
    }
}
