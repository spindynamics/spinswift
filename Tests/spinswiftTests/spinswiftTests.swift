import XCTest
@testable import spinswift
@testable import CGSL

final class spinswiftTests: XCTestCase {
    func testPeriodicTable() throws {
        XCTAssertEqual(PeriodicTable().radius("Oxygen",method:"calc"), 48)
        XCTAssertEqual(PeriodicTable().Z_label("Iron"), "Fe")
    }
    func testGSL() throws {
        XCTAssertEqual(gsl_sf_bessel_J0(1.0),0.7651976865579666)
    }
}
