import XCTest
@testable import VaultsLib

final class VaultsLibTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(VaultsLib().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
