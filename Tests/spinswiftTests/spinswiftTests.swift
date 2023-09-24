import XCTest
@testable import spinswift

final class spinswiftTests: XCTestCase {
    func testPeriodicTable() throws {
        XCTAssertEqual(PeriodicTable().radius("Oxygen",method:"calc"), 48)
        XCTAssertEqual(PeriodicTable().Z_label("Iron"), "Fe")
    }
}
