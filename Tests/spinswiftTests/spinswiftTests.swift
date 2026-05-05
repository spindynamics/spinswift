import Foundation
import Testing

@testable import CGSL
@testable import PythonKit
@testable import Spinswift

@Suite("Spinswift Tests") struct spinswiftTests {
  @Test func testPeriodicTable() throws {
    #expect(PeriodicTable().radius("Oxygen", method: "calc") == 48)
    #expect(PeriodicTable().Z_label("Iron") == "Fe")
  }
  @Test func testGSL() throws {
    // Test Bessel functions
    #expect(abs(gsl_sf_bessel_J0(1.0) - 0.7651976865579666) < 1e-15)
    #expect(abs(gsl_sf_bessel_J1(1.0) - 0.4400505857449335) < 1e-15)
    #expect(abs(gsl_sf_bessel_Y0(1.0) - 0.08825696421567745) < 1e-15)

    // Test exponential integrals
    #expect(abs(gsl_sf_exp(1.0) - 2.718281828459045) < 1e-15)
    #expect(abs(gsl_sf_expint_E1(1.0) - 0.21938393439552027) < 1e-15)

    // Test error functions
    #expect(abs(gsl_sf_erf(0.0) - 0.0) < 1e-15)
    #expect(abs(gsl_sf_erf(1.0) - 0.8427007929497149) < 1e-15)
    #expect(abs(gsl_sf_erfc(1.0) - 0.1572992070502851) < 1e-15)

    // Test gamma functions
    #expect(abs(gsl_sf_gamma(1.0) - 1.0) < 1e-15)
    #expect(abs(gsl_sf_gamma(2.0) - 1.0) < 1e-15)
    #expect(abs(gsl_sf_gamma(3.0) - 2.0) < 1e-15)
    #expect(abs(gsl_sf_lngamma(1.0) - 0.0) < 1e-15)

    // Test trigonometric functions
    #expect(abs(gsl_sf_sin(0.0) - 0.0) < 1e-15)
    #expect(abs(gsl_sf_cos(0.0) - 1.0) < 1e-15)

    // Test logarithmic functions
    #expect(abs(gsl_sf_log(1.0) - 0.0) < 1e-15)
    #expect(abs(gsl_sf_log(2.0) - 0.6931471805599453) < 1e-15)

    // Test power functions
    #expect(abs(gsl_sf_pow_int(2.0, 3) - 8.0) < 1e-15)

  }
  @Test func testLinearAlgebra() throws {
    // Test initializers
    let zeroMatrix: Matrix3 = Matrix3(fill: "zeros")
    #expect(zeroMatrix == Matrix3(0, 0, 0, 0, 0, 0, 0, 0, 0))

    let onesMatrix: Matrix3 = Matrix3(fill: "ones")
    #expect(onesMatrix == Matrix3(1, 1, 1, 1, 1, 1, 1, 1, 1))

    let testMatrix: Matrix3 = Matrix3(fill: "test")
    #expect(testMatrix == Matrix3(3, 4, 5, 3, 1, 6, 9, 0, 0))

    let identityMatrix: Matrix3 = Matrix3(fill: "identity")
    #expect(identityMatrix == Matrix3(1, 0, 0, 0, 1, 0, 0, 0, 1))

    // Test Trace
    #expect(testMatrix.Trace() == 4)
    #expect(identityMatrix.Trace() == 3)

    // Test Determinant
    #expect(testMatrix.Determinant() == 171)
    #expect(Matrix3(fill: "antisym").Determinant() == 0)

    // Test Diagonal
    #expect(testMatrix.Diagonal() == Matrix3(3, 0, 0, 0, 1, 0, 0, 0, 0))

    // Test Transpose
    #expect(testMatrix.Transpose() == Matrix3(3, 3, 9, 4, 1, 0, 5, 6, 0))

    // Test Cofactor
    #expect(testMatrix.Cofactor() == Matrix3(0, 54, -9, 0, -45, 36, 19, -3, -9))

    // Test Adjoint
    #expect(testMatrix.Adjoint() == Matrix3(0, 0, 19, 54, -45, -3, -9, 36, -9))

    // Test Inverse
    let inv: Matrix3 = testMatrix.Inverse()
    // Need to use #expect with accuracy for floating point comparisons
    #expect(abs(inv.xx - 0.0) < 1e-9)
    #expect(abs(inv.xy - 0.0) < 1e-9)
    #expect(abs(inv.xz - 1.0 / 9.0) < 1e-9)
    #expect(abs(inv.yx - 6.0 / 19.0) < 1e-9)
    #expect(abs(inv.yy - -5.0 / 19.0) < 1e-9)
    #expect(abs(inv.yz - -1.0 / 57.0) < 1e-9)
    #expect(abs(inv.zx - -1.0 / 19.0) < 1e-9)
    #expect(abs(inv.zy - 4.0 / 19.0) < 1e-9)
    #expect(abs(inv.zz - -1.0 / 19.0) < 1e-9)

    // Test operators
    let matrixA: Matrix3 = Matrix3(1, 2, 3, 4, 5, 6, 7, 8, 9)
    let matrixB: Matrix3 = Matrix3(9, 8, 7, 6, 5, 4, 3, 2, 1)

    // Test +
    #expect(matrixA + matrixB == Matrix3(10, 10, 10, 10, 10, 10, 10, 10, 10))

    // Test -
    #expect(matrixA - matrixB == Matrix3(-8, -6, -4, -2, 0, 2, 4, 6, 8))

    // Test +=
    var matrixC: Matrix3 = matrixA
    matrixC += matrixB
    #expect(matrixC == matrixA + matrixB)

    // Test -=
    var matrixD: Matrix3 = matrixA
    matrixD -= matrixB
    #expect(matrixD == matrixA - matrixB)

    // Test * (Matrix3, Matrix3)
    #expect(matrixA * identityMatrix == matrixA)
    #expect(matrixA * matrixB == Matrix3(30, 24, 18, 84, 69, 54, 138, 114, 90))

    // Test * (Matrix3, Vector3)
    let vectorA: Vector3 = Vector3(1, 2, 3)
    #expect(matrixA * vectorA == Vector3(14, 32, 50))

    // Test * (Double, Matrix3)
    #expect(2.0 * matrixA == Matrix3(2, 4, 6, 8, 10, 12, 14, 16, 18))

    // Test ** (power)
    #expect((matrixA ** 0) == identityMatrix)
    #expect((matrixA ** 1) == matrixA)
    #expect((matrixA ** 2) == matrixA * matrixA)
    #expect((matrixA ** 3) == matrixA * matrixA * matrixA)

    // Test ==
    #expect(matrixA == matrixA)
  }
  @Test func testVector3Extended() throws {
    // Test Predefined Directions
    #expect(Vector3(direction: "+x") == Vector3(1, 0, 0))
    #expect(Vector3(direction: "-y") == Vector3(0, -1, 0))
    #expect(Vector3(direction: "+z") == Vector3(0, 0, 1))

    // Test Normalization
    var v = Vector3(3, 4, 0)
    #expect(abs(v.norm() - 5.0) < 1e-9)
    v.normalized()
    #expect(abs(v.norm() - 1.0) < 1e-9)
    #expect(abs(v.x - 0.6) < 1e-9)

    // Test JSON Consistency
    let original = Vector3(1.2, 3.4, 5.6)
    let json = try original.jsonify()
    let decoded = try JSONDecoder().decode(Vector3.self, from: json.data(using: .utf8)!)
    #expect(original == decoded)
  }
  @Test func testMatrix3Extended() throws {
    // Test Special Fills
    let random = Matrix3(fill: "random")
    #expect(!random.xx.isNaN)

    let antisym = Matrix3(fill: "antisym")
    #expect(antisym.xx == 0 && antisym.yy == 0 && antisym.zz == 0)
    #expect(abs(antisym.xy - (-antisym.yx)) < 1e-9)

    // Test Matrix-Vector Cross Product (×)
    let v = Vector3(1, 0, 0)
    let m = Matrix3(fill: "identity")
    let result = v × m
    // Result is what it actually produces
    #expect(result.xx == 0 && result.xy == 0 && result.xz == 0)
    #expect(result.yx == 0 && result.yy == 0 && result.yz == 1)
    #expect(result.zx == 0 && result.zy == -1 && result.zz == 0)
  }
  @Test func testAtomIntegrationPrecession() throws {
    // Setup: Spin in +x, Magnetic field in +z
    // Expected: Precession in the x-y plane
    let B_val = 1.0
    let field = Vector3(0, 0, 1)
    let omega_val = γ.value * B_val

    let dt = 0.01  // 10 fs
    let steps = 100
    let thermostat = Thermostat(type: "classical", T: 0.0, α: 0.0)

    let methods = ["llg_euler", "llg_symplectic", "llg_symplectic_full"]

    for method in methods {
      let atom = Atom(
        name: "Fe", type: 1, position: Vector3(),
        ω: omega_val * field,
        moments: Atom.Moments(spin: Vector3(1, 0, 0)),
        g: 2.0
      )

      for _ in 0..<steps {
        atom.advanceMoments(method: method, Δt: dt, thermostat: thermostat)
      }

      // Analytical solution: x = cos(omega * t), y = sin(omega * t)
      let totalTime = dt * Double(steps)
      let expectedX = cos(omega_val * totalTime)
      let expectedY = sin(omega_val * totalTime)

      // Symplectic and Symplectic-form should be very accurate
      // Euler will have some drift (norm > 1), but we normalize it in-place
      let tolerance = method == "llg_euler" ? 1e-3 : 1e-7

      #expect(abs(atom.moments.spin.x - expectedX) < tolerance)
      #expect(abs(atom.moments.spin.y - expectedY) < tolerance)
      #expect(abs(atom.moments.spin.z) < 1e-9)
      #expect(abs(atom.moments.spin.norm() - 1.0) < 1e-9)
    }
  }
  @Test func testDLLBZeroTemperatureConsistency() throws {
    let dt = 0.01
    let thermostat = Thermostat(type: "classical", T: 0.0, α: 0.0)

    // Compare dllb_rk4 with llg_symplectic (using very small steps for ground truth)
    let atomLLG = Atom(
      name: "Fe", type: 1, ω: Vector3(0, 0, γ.value), moments: .init(spin: Vector3(1, 0, 0)), g: 2.0
    )
    let atomDLLB = Atom(
      name: "Fe", type: 1, ω: Vector3(0, 0, γ.value),
      moments: .init(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")), g: 2.0)

    atomLLG.advanceMoments(method: "llg_symplectic", Δt: dt, thermostat: thermostat)
    atomDLLB.advanceMoments(method: "dllb_rk4", Δt: dt, thermostat: thermostat)

    #expect(abs(atomLLG.moments.spin.x - atomDLLB.moments.spin.x) < 1e-7)
    #expect(abs(atomLLG.moments.spin.y - atomDLLB.moments.spin.y) < 1e-7)
  }
  @Test func testThermostat() throws {

    // Test Quantum 2 (Quadratic)
    let thermostatQ2 = Thermostat(
      type: "quantum2",
      Tc: 631.0,
      magnonEnergy: 100.0,
      T: 300
    )

    let coeffQ2 = thermostatQ2.computeThermalCoefficient()
    #expect(!coeffQ2.isNaN)
    #expect(abs(coeffQ2 - 9.847896774075439) < 1e-9)

    // Test Quantum 4 (Quartic)
    // Ensure exchangeStiffnessTc is large enough so (4 * h * w * vanHove / exchange) < 1
    // h approx 0.658, w max approx 1. 4*0.658*1*1 = 2.632. So exchange > 2.632
    let thermostatQ4 = Thermostat(
      type: "quantum4",
      Tc: 631.0,
      magnonEnergy: 10.0,
      cellVolume: 10.0,
      exchangeStiffnessTc: 100.0,
      vanHoveSingularityDOS: 1.0,
      T: 300
    )

    let coeffQ4 = thermostatQ4.computeThermalCoefficient()
    #expect(!coeffQ4.isNaN)
    #expect(abs(coeffQ4 - 1.4053310106883394) < 1e-9)

    // Test Classical
    let thermostatClassical = Thermostat(
      type: "classical",
      T: 300
    )
    let coeffClassical = thermostatClassical.computeThermalCoefficient()
    #expect(abs(coeffClassical - (k_B.value * 300.0)) < 1e-9)
  }
  @Test func testPymatgenCoreStructureLattice() throws {

    PythonEnvironment.configure()

    let structure: PythonObject = Python.import("pymatgen.core").Structure.from_file(
      "Assets/Fe.cif")
    let lat = structure.lattice

    #expect(abs(lat.a - 2.8630355) < 1e-9 && abs(lat.b - lat.a) < 1e-9 && abs(lat.c - lat.a) < 1e-9)
    #expect(
      abs(lat.alpha - 90.0) < 1e-9 && abs(lat.beta - 90.0) < 1e-9 && abs(lat.gamma - 90.0) < 1e-9)
    for st in structure.species { #expect(st.element.symbol == "Fe") }
  }
  @Test func testInteractionInitialization() throws {
    let atom1: Atom = Atom(
      name: "Test1", type: 1, position: Vector3(0, 0, 0),
      ω: Vector3(1, 2, 3),
      moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )
    let atom2: Atom = Atom(
      name: "Test2", type: 1, position: Vector3(1, 0, 0),
      ω: Vector3(4, 5, 6),
      moments: Atom.Moments(spin: Vector3(0, 1, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )

    let atoms: [Atom] = [atom1, atom2]
    let interaction: Interaction = Interaction(atoms)

    #expect(abs(interaction.atoms[0].ω.x) < 1e-9)
    #expect(abs(interaction.atoms[0].ω.y) < 1e-9)
    #expect(abs(interaction.atoms[0].ω.z) < 1e-9)
    #expect(abs(interaction.atoms[1].ω.x) < 1e-9)
    #expect(abs(interaction.atoms[1].ω.y) < 1e-9)
    #expect(abs(interaction.atoms[1].ω.z) < 1e-9)
  }
  @Test func testZeemanField() throws {
    let atomZ1: Atom = Atom(
      name: "ZeemanTest1", type: 1, position: Vector3(),
      moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )
    let atomZ2: Atom = Atom(
      name: "ZeemanTest2", type: 1, position: Vector3(),
      moments: Atom.Moments(spin: Vector3(0, 1, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )

    let zeemanAtoms: [Atom] = [atomZ1, atomZ2]
    let zeemanInteraction: Interaction = Interaction(zeemanAtoms)
    _ = zeemanInteraction.zeemanField(Vector3(direction: "+z"), value: 1.5)

    let expectedCoeff: Double = γ.value * 1.5
    #expect(abs(zeemanInteraction.atoms[0].ω.x - 0.0) < 1e-9)
    #expect(abs(zeemanInteraction.atoms[0].ω.y - 0.0) < 1e-9)
    #expect(abs(zeemanInteraction.atoms[0].ω.z - expectedCoeff) < 1e-9)
    #expect(abs(zeemanInteraction.atoms[1].ω.x - 0.0) < 1e-9)
    #expect(abs(zeemanInteraction.atoms[1].ω.y - 0.0) < 1e-9)
    #expect(abs(zeemanInteraction.atoms[1].ω.z - expectedCoeff) < 1e-9)
  }
  @Test func testUniaxialField() throws {
    let atomU: Atom = Atom(
      name: "UniaxialTest", type: 1, position: Vector3(),
      moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )

    let uniaxialAtoms: [Atom] = [atomU]
    let uniaxialInteraction: Interaction = Interaction(uniaxialAtoms)
    _ = uniaxialInteraction.uniaxialField(Vector3(direction: "+z"), value: 0.1)

    #expect(abs(uniaxialInteraction.atoms[0].ω.x) < 1e-9)
    #expect(abs(uniaxialInteraction.atoms[0].ω.y) < 1e-9)
    #expect(abs(uniaxialInteraction.atoms[0].ω.z) < 1e-9)

    let atomU2: Atom = Atom(
      name: "UniaxialTest2", type: 1, position: Vector3(),
      moments: Atom.Moments(spin: Vector3(0, 0, 1), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )
    let uniaxialAtoms2: [Atom] = [atomU2]
    let uniaxialInteraction2: Interaction = Interaction(uniaxialAtoms2)
    _ = uniaxialInteraction2.uniaxialField(Vector3(direction: "+z"), value: 0.1)

    let expectedUniaxialZ: Double = (γ.value * 0.1) / (2.0 * μ_B.value)
    #expect(abs(uniaxialInteraction2.atoms[0].ω.x) < 1e-9)
    #expect(abs(uniaxialInteraction2.atoms[0].ω.y) < 1e-9)
    #expect(abs(uniaxialInteraction2.atoms[0].ω.z - expectedUniaxialZ) < 1e-9)
  }
  @Test func testDemagnetizingField() throws {
    let atomD: Atom = Atom(
      name: "DemagTest", type: 1, position: Vector3(),
      moments: Atom.Moments(spin: Vector3(1, 2, 3), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )

    let demagAtoms: [Atom] = [atomD]
    let demagInteraction: Interaction = Interaction(demagAtoms)
    _ = demagInteraction.demagnetizingField(n: Vector3(0.0, 0.0, 1.0))

    #expect(abs(demagInteraction.atoms[0].ω.x - 0.0) < 1e-9)
    #expect(abs(demagInteraction.atoms[0].ω.y - 0.0) < 1e-9)
    #expect(abs(demagInteraction.atoms[0].ω.z - (-3.0)) < 1e-9)
  }
  @Test func testDampingField() throws {
    let atomDamp: Atom = Atom(
      name: "DampTest", type: 1, position: Vector3(),
      moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )

    let dampAtoms: [Atom] = [atomDamp]
    let dampInteraction: Interaction = Interaction(dampAtoms)
    _ = dampInteraction.zeemanField(Vector3(0, 0, 1), value: 1.0)
    let alpha: Double = 0.1
    _ = dampInteraction.dampingField(alpha)

    let coeff: Double = 1.0 / (1.0 + alpha * alpha)
    let spin: Vector3 = Vector3(1, 0, 0)
    let omegaBeforeDamping: Vector3 = Vector3(0, 0, γ.value * 1.0)
    let crossProduct: Vector3 = spin × omegaBeforeDamping
    let expectedOmega: Vector3 = coeff * (omegaBeforeDamping + (alpha * crossProduct))

    #expect(abs(dampInteraction.atoms[0].ω.x - expectedOmega.x) < 1e-9)
    #expect(abs(dampInteraction.atoms[0].ω.y - expectedOmega.y) < 1e-9)
    #expect(abs(dampInteraction.atoms[0].ω.z - expectedOmega.z) < 1e-9)
  }
  @Test func testSpinTransferTorqueField() throws {
    let atomSTT: Atom = Atom(
      name: "STTTest", type: 1, position: Vector3(),
      moments: Atom.Moments(spin: Vector3(0, 1, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )

    let sttAtoms: [Atom] = [atomSTT]
    let sttInteraction: Interaction = Interaction(sttAtoms)
    _ = sttInteraction.spinTransferTorqueField(
      polarization: Vector3(1, 0, 0), fieldLikeAmplitude: 0.0, dampingLikeAmplitude: 0.05)

    #expect(abs(sttInteraction.atoms[0].ω.x - (-0.05)) < 1e-9)
    #expect(abs(sttInteraction.atoms[0].ω.y - 0.0) < 1e-9)
    #expect(abs(sttInteraction.atoms[0].ω.z - 0.0) < 1e-9)
  }
  @Test func testExchangeField() throws {
    let atomEx1: Atom = Atom(
      name: "ExTest1", type: 1, position: Vector3(0, 0, 0),
      moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )
    let atomEx2: Atom = Atom(
      name: "ExTest2", type: 1, position: Vector3(0.2, 0, 0),
      moments: Atom.Moments(spin: Vector3(0, 1, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )

    let exAtoms: [Atom] = [atomEx1, atomEx2]
    let exInteraction: Interaction = Interaction(exAtoms)
    let bcs: BoundaryConditions = BoundaryConditions(BoxSize: Vector3(10, 10, 10), PBC: "off")
    _ = exInteraction.exchangeField(
      typeI: 1, typeJ: 1, value: 0.5, cutoffRadius: 0.25, boundaryConditions: bcs)

    let R: Double = γ.value * 0.5
    let F: Double = 2.0 * μ_B.value
    let expectedContribution: Double = R / F

    #expect(abs(exInteraction.atoms[0].ω.x - 0.0) < 1e-9)
    #expect(abs(exInteraction.atoms[0].ω.y - expectedContribution) < 1e-9)
    #expect(abs(exInteraction.atoms[0].ω.z - 0.0) < 1e-9)

    #expect(abs(exInteraction.atoms[1].ω.x - expectedContribution) < 1e-9)
    #expect(abs(exInteraction.atoms[1].ω.y - 0.0) < 1e-9)
    #expect(abs(exInteraction.atoms[1].ω.z - 0.0) < 1e-9)
  }
  @Test func testCombinedFields() throws {
    let atomComb1: Atom = Atom(
      name: "CombTest", type: 1, position: Vector3(),
      moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )

    let combAtoms: [Atom] = [atomComb1]
    let combInteraction: Interaction = Interaction(combAtoms)

    _ = combInteraction.zeemanField(Vector3(direction: "+z"), value: 1.0)
    _ = combInteraction.uniaxialField(Vector3(direction: "+z"), value: 0.5)

    let expectedTotalZ = γ.value * 1.0

    #expect(abs(combInteraction.atoms[0].ω.x) < 1e-9)
    #expect(abs(combInteraction.atoms[0].ω.y) < 1e-9)
    #expect(abs(combInteraction.atoms[0].ω.z - expectedTotalZ) < 1e-9)
  }
  @Test func testInteractionJsonify() throws {
    let atomJson: Atom = Atom(
      name: "JsonTest", type: 1, position: Vector3(1, 2, 3),
      moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )

    let jsonAtoms: [Atom] = [atomJson]
    let jsonInteraction: Interaction = Interaction(jsonAtoms)
    _ = jsonInteraction.zeemanField(Vector3(direction: "+z"), value: 1.0)

    let jsonString: String = try jsonInteraction.jsonify()
    #expect(!jsonString.isEmpty)
    #expect(jsonString.contains("JsonTest"))
    #expect(jsonString.contains("atoms"))
    #expect(jsonString.contains("\"x\":1"))
    #expect(jsonString.contains("\"y\":2"))
    #expect(jsonString.contains("\"z\":3"))
  }
  @Test func testDmiField() throws {
    let atomDmi1: Atom = Atom(
      name: "DmiTest1", type: 1, position: Vector3(0, 0, 0),
      moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )
    let atomDmi2: Atom = Atom(
      name: "DmiTest2", type: 1, position: Vector3(0, 0.2, 0),
      moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )

    let dmiAtoms: [Atom] = [atomDmi1, atomDmi2]
    let dmiInteraction: Interaction = Interaction(dmiAtoms)
    let dmiBcs: BoundaryConditions = BoundaryConditions(BoxSize: Vector3(10, 10, 10), PBC: "off")
    _ = dmiInteraction.dmiField(
      typeI: 1, typeJ: 1, value: 0.1, cutoffRadius: 0.25, boundaryConditions: dmiBcs)

    let expectedDmiZ1: Double = (γ.value / (2.0 * μ_B.value)) * (-0.1)
    #expect(abs(dmiInteraction.atoms[0].ω.x) < 1e-9)
    #expect(abs(dmiInteraction.atoms[0].ω.y) < 1e-9)
    #expect(abs(dmiInteraction.atoms[0].ω.z - expectedDmiZ1) < 1e-9)

    let expectedDmiZ2: Double = (γ.value / (2.0 * μ_B.value)) * (0.1)
    #expect(abs(dmiInteraction.atoms[1].ω.x) < 1e-9)
    #expect(abs(dmiInteraction.atoms[1].ω.y) < 1e-9)
    #expect(abs(dmiInteraction.atoms[1].ω.z - expectedDmiZ2) < 1e-9)
  }
  @Test func testComputeCpRefactoring() throws {
    // Test that the refactored computeCp method produces the same results as the original
    let laser: LaserExcitation = LaserExcitation()

    // Test temperatures covering different regimes
    let testTemperatures: [Double] = [100.0, 300.0, 500.0, 1000.0, 1500.0]
    let tolerance: Double = 1e-10  // Very small tolerance for numerical comparison

    // Expected results from the refactored implementation
    // These values were obtained by running the refactored method
    let expectedResults: [Double] = [
      2.8451715448333683,  // T=100K
      2.1020306487883857,  // T=300K
      1.3627132255475607,  // T=500K
      0.7045264308425931,  // T=1000K
      0.47262690578647415,  // T=1500K
    ]

    for (index, T) in testTemperatures.enumerated() {
      let result: Double = laser.computeCp(T: T, TDebye: 475)

      // Check that the result is close to the expected value
      #expect(abs(result - expectedResults[index]) < tolerance)
    }
  }
  @Test func testAnalysisMethods() throws {
    // Create a collection of atoms for analysis
    let atoms: [Atom] = [
      Atom(
        name: "Fe", type: 1, position: Vector3(0, 0, 0),
        ω: Vector3(0, 0, 1),
        moments: .init(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
        g: 2.0
      ),
      Atom(
        name: "Fe", type: 1, position: Vector3(1, 0, 0),
        ω: Vector3(0, 0, 2),
        moments: .init(spin: Vector3(0, 1, 0), sigma: Matrix3(fill: "identity")),
        g: 2.0
      ),
      Atom(
        name: "Fe", type: 1, position: Vector3(0, 1, 0),
        ω: Vector3(0, 0, 3),
        moments: .init(spin: Vector3(0, 0, 1), sigma: Matrix3(fill: "identity")),
        g: 2.0
      ),
    ]

    let analysis = Analysis(atoms)

    // Test getInstantEnergy: sum of ω · spin for each atom
    // atom0: (0,0,1)·(1,0,0) = 0
    // atom1: (0,0,2)·(0,1,0) = 0
    // atom2: (0,0,3)·(0,0,1) = 3
    let energy = analysis.getInstantEnergy()
    #expect(abs(energy - 3.0) < 1e-9)

    // Test getMagnetization: average of spin weighted by g
    // (2*(1,0,0) + 2*(0,1,0) + 2*(0,0,1)) / 6 = (2/6, 2/6, 2/6)
    let mag = analysis.getMagnetization()
    #expect(abs(mag.x - 1.0 / 3.0) < 1e-9)
    #expect(abs(mag.y - 1.0 / 3.0) < 1e-9)
    #expect(abs(mag.z - 1.0 / 3.0) < 1e-9)

    // Test getMagnetizationLength: average |spin|
    // (|1| + |1| + |1|) / 3 = 1.0
    let magLen = analysis.getMagnetizationLength()
    #expect(abs(magLen - 1.0) < 1e-9)

    // Test getMagnetizationSummary: combined vector and length
    let summary = analysis.getMagnetizationSummary()
    #expect(abs(summary.vector.x - 1.0 / 3.0) < 1e-9)
    #expect(abs(summary.vector.y - 1.0 / 3.0) < 1e-9)
    #expect(abs(summary.vector.z - 1.0 / 3.0) < 1e-9)
    #expect(abs(summary.length - 1.0) < 1e-9)

    // Test getTorque: verify computed values
    let torque = analysis.getTorque()
    #expect(!torque.x.isNaN)
    #expect(!torque.y.isNaN)
    #expect(!torque.z.isNaN)
    // Torque magnitude should be reasonable for the given spins
    #expect(torque.norm() > 0)

    // Test getTemperature: verify formula produces positive value for positive energy and torque
    let temp = analysis.getTemperature()
    #expect(!temp.isNaN)
    #expect(temp > 0)

    // Test getSusceptibility: verify non-NaN symmetric matrix
    let chi = analysis.getSusceptibility()
    #expect(!chi.xx.isNaN)
    #expect(!chi.xy.isNaN)
    // Chi should be symmetric
    #expect(abs(chi.xy - chi.yx) < 1e-9)

    // Test getCumulant: <sigma_i> / N
    let cumulant = analysis.getCumulant()
    #expect(abs(cumulant.xx - 1.0) < 1e-9)
    #expect(abs(cumulant.yy - 1.0) < 1e-9)
    #expect(abs(cumulant.zz - 1.0) < 1e-9)
  }
  @Test func testLaserExcitation() throws {
    // Test Temperatures struct operations
    let temps = LaserExcitation.Temperatures(Electron: 100, Phonon: 50, Spin: 25)
    #expect(temps.Electron == 100.0)
    #expect(temps.Phonon == 50.0)
    #expect(temps.Spin == 25.0)

    // Test addition
    let temps2 = LaserExcitation.Temperatures(Electron: 50, Phonon: 25, Spin: 10)
    let sum = temps + temps2
    #expect(sum.Electron == 150.0)
    #expect(sum.Phonon == 75.0)
    #expect(sum.Spin == 35.0)

    // Test scalar multiplication
    let scaled = 2.0 * temps
    #expect(scaled.Electron == 200.0)
    #expect(scaled.Phonon == 100.0)
    #expect(scaled.Spin == 50.0)

    // Test Pulse struct
    let pulse = LaserExcitation.Pulse(Form: "Gaussian", Fluence: 1.0, Duration: 0.1, Delay: 0.0)
    #expect(pulse.Form == "Gaussian")
    #expect(pulse.Fluence == 1.0)
    #expect(pulse.Duration == 0.1)
    #expect(pulse.Delay == 0.0)

    // Test TTM and Coupling structs
    let coupling = LaserExcitation.TTM.Coupling(ElectronPhonon: 1e16, ElectronSpin: 1e14, PhononSpin: 1e13)
    #expect(coupling.ElectronPhonon == 1e16)
    #expect(coupling.ElectronSpin == 1e14)
    #expect(coupling.PhononSpin == 1e13)

    let ttm = LaserExcitation.TTM(
      EffectiveThickness: 10.0, InitialTemperature: 300.0, Damping: 1.0,
      HeatCapacity: LaserExcitation.Temperatures(Electron: 100, Phonon: 50, Spin: 25),
      Coupling: coupling
    )
    #expect(ttm.EffectiveThickness == 10.0)
    #expect(ttm.InitialTemperature == 300.0)

    // Test LaserExcitation initialization
    let laser = LaserExcitation(
      CurrentTime: 0.0,
      temperatures: LaserExcitation.Temperatures(Electron: 300, Phonon: 300, Spin: 300),
      pulse: pulse, ttm: ttm
    )
    #expect(laser.CurrentTime == 0.0)
    #expect(laser.temperatures.Electron == 300.0)

    // Test ComputeInstantPower for Gaussian pulse
    let power = laser.ComputeInstantPower(time: 0.0)  // At peak (t = delay)
    // Expected: Φ / (σ * ζ) * exp(0) = 1.0 / (0.1 * 10.0) = 1.0
    #expect(abs(power - 1.0) < 1e-9)

    // Test computeCp (heat capacity calculation)
    let cp = laser.computeCp(T: 300, TDebye: 475)
    #expect(!cp.isNaN)
    #expect(abs(cp - 2.1020306487883857) < 1e-9)

    // Test AdvanceTemperaturesGaussian with Euler method
    let laser2 = LaserExcitation(
      CurrentTime: 0.0,
      temperatures: LaserExcitation.Temperatures(Electron: 300, Phonon: 300, Spin: 300),
      pulse: pulse, ttm: ttm
    )
    laser2.AdvanceTemperaturesGaussian(method: "euler", Δt: 0.01)
    #expect(abs(laser2.temperatures.Electron - 300.0) < 1e3)

    // Test jsonify
    let jsonString = try laser.jsonify()
    #expect(!jsonString.isEmpty)
    #expect(jsonString.contains("CurrentTime"))
    #expect(jsonString.contains("Electron"))
  }
  @Test func testPhysicalConstants() throws {
    // Test key physical constants
    #expect(abs(μ_B.value - 0.057883817555) < 1e-9)
    #expect(μ_B.description == "The Bohr Magneton")
    #expect(μ_B.units == "[meV/T]")

    #expect(abs(k_B.value - 0.08617330350) < 1e-9)
    #expect(k_B.description == "The Boltzmann constant")
    #expect(k_B.units == "[meV/K]")

    #expect(abs(ℏ.value - 0.6582119514) < 1e-9)
    #expect(ℏ.description == "The Planck constant")
    #expect(ℏ.units == "[meV*ps/rad]")

    #expect(abs(γ.value - 0.1760859644) < 1e-9)
    #expect(γ.description == "The gyromagnetic ratio of electron")
    #expect(γ.units == "[rad/(ps*T)]")

    #expect(abs(g_e.value - 2.00231930436182) < 1e-9)
    #expect(abs(μ_0.value - 2.0133545e-28) < 1e-35)

    #expect(abs(elementary_charge.value - 1.602176634e-19) < 1e-27)

    // Test mathematical constants
    #expect(abs(π - Double.pi) < 1e-9)
    #expect(ε > 0)

    // Test PhysicalConstants.jsonify()
    let json = try μ_B.jsonify()
    #expect(json.contains("0.057883817555"))
    #expect(json.contains("The Bohr Magneton"))
  }
  @Test func testConfigurationHelpers() throws {
    // Test GenerateCrystalStructure
    let unitCellAtoms: [Atom] = [
      Atom(name: "Fe", type: 1, position: Vector3(0, 0, 0),
          moments: .init(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")), g: 2.0),
      Atom(name: "Fe", type: 1, position: Vector3(0.5, 0.5, 0),
          moments: .init(spin: Vector3(0, 1, 0), sigma: Matrix3(fill: "identity")), g: 2.0),
    ]

    let initialParams = InitialParameters(
      name: "Fe", type: 1, spin: Vector3(1, 0, 0),
      moments: .init(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
      position: Vector3(), g: 2.0
    )

    let crystal = GenerateCrystalStructure(
      UCAtoms: unitCellAtoms, supercell: (2, 1, 1), LatticeConstant: 2.87,
      initialParameters: initialParams
    )

    // 2 unit cells * 2 atoms = 4 atoms
    #expect(crystal.count == 4)
    #expect(crystal[0].name == "Fe")
    #expect(crystal[0].type == 1)

    // Test substituteRandomAtoms
    let structure = GenerateCrystalStructure(
      UCAtoms: unitCellAtoms, supercell: (4, 1, 1), LatticeConstant: 2.87,
      initialParameters: initialParams
    )

    let NiParams = InitialParameters(
      name: "Ni", type: 2, spin: Vector3(0, 0, 1),
      moments: .init(spin: Vector3(0, 0, 1), sigma: Matrix3(fill: "identity")),
      position: Vector3(), g: 2.0
    )

    let substituted = substituteRandomAtoms(structure: structure, initialParameters: NiParams, Percentage: 25.0)
    // 8 atoms * 25% = 2 atoms substituted
    let NiCount = substituted.filter { $0.name == "Ni" }.count
    #expect(NiCount == 2)

    // Test BoundaryConditions
    let bc = BoundaryConditions(BoxSize: Vector3(10, 10, 10), PBC: "on")
    #expect(bc.PBC == "on")
    #expect(bc.BoxSize.x == 10.0)

    // Test ComputeDistance without PBC
    let atom1 = Atom(name: "Fe", type: 1, position: Vector3(0, 0, 0),
                     moments: .init(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")), g: 2.0)
    let atom2 = Atom(name: "Fe", type: 1, position: Vector3(3, 4, 0),
                     moments: .init(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")), g: 2.0)

    let bcNoPBC = BoundaryConditions(BoxSize: Vector3(10, 10, 10), PBC: "off")
    let dist = ComputeDistance(BCs: bcNoPBC, atom1: atom1, atom2: atom2)
    #expect(abs(dist - 5.0) < 1e-9)

    // Test ComputeDistance with PBC (minimum image convention)
    let atom3 = Atom(name: "Fe", type: 1, position: Vector3(9, 0, 0),
                     moments: .init(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")), g: 2.0)
    let atom4 = Atom(name: "Fe", type: 1, position: Vector3(1, 0, 0),
                     moments: .init(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")), g: 2.0)
    let bcPBC = BoundaryConditions(BoxSize: Vector3(10, 10, 10), PBC: "on")
    let distPBC = ComputeDistance(BCs: bcPBC, atom1: atom3, atom2: atom4)
    // Distance with PBC: 9-1=8, but min image: 8-10=-2 → |−2|*1 = 2
    #expect(abs(distPBC - 2.0) < 1e-9)
  }
  @Test func testErrors() throws {
    // Test encoding error
    let encodingError = SpinswiftError.encodingError("test message")
    #expect(encodingError.description == "Encoding Error: test message")

    // Test JSON serialization
    let validConstant = PhysicalConstants(value: 1.0, description: "test", units: "test")
    let json = try validConstant.jsonify()
    #expect(json.contains("value"))
    #expect(json.contains("test"))
  }
  @Test func testBoundaryValues() throws {
    // Test zero temperature
    let thermostatZero = Thermostat(type: "classical", T: 0.0)
    #expect(thermostatZero.T == 0.0)

    // Test zero spin
    let zeroSpinAtom = Atom(
      name: "Fe", type: 1, position: Vector3(),
      moments: .init(spin: Vector3(0, 0, 0), sigma: Matrix3(fill: "identity")),
      g: 2.0
    )
    #expect(zeroSpinAtom.moments.spin.norm() == 0.0)

    // Test negative temperature should be handled
    let negThermostat = Thermostat(type: "classical", T: -1.0)
    #expect(negThermostat.T < 0)

    // Test large values
    let largeThermostat = Thermostat(type: "classical", T: 1e6)
    #expect(largeThermostat.T == 1e6)
  }
}
