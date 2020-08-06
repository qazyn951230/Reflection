import XCTest
@testable import Reflection

final class ReflectionTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Reflection().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
