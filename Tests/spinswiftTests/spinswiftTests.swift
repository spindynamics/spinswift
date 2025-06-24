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
    func testLinearAlgebra() throws {
         XCTAssertTrue(Matrix3(fill:"test").Transpose() == Matrix3(3,3,9,4,1,0,5,6,0))
         XCTAssertTrue(Matrix3(fill:"test").Inverse() == Matrix3(0,0,1/9,6/19,-5/19,-1/57,-1/19,4/19,-1/19))
         XCTAssertTrue(Matrix3(fill:"test").Cofactor() == Matrix3(0,54,-9,0,-45,36,19,-3,-9))
         XCTAssertTrue(Matrix3(fill:"test").Adjoint() == Matrix3(0,0,19,54,-45,-3,-9,36,-9))
         XCTAssertTrue(Matrix3(fill:"test").Diag() == Matrix3(3,0,0,0,1,0,0,0,0))
         XCTAssertEqual(Matrix3(fill:"test").Det(),171)
         XCTAssertEqual(Matrix3(fill:"test").Trace(),4)
         XCTAssertEqual(Matrix3(fill:"antisym").Det(),0)
    }
}
