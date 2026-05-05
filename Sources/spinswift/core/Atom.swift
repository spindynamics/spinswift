/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

import Foundation

/// A class representing an atom with magnetic properties and spin dynamics.
///
/// This class manages the physical properties of an atom, including its position,
/// Landé factor, and spin moments. It provides methods for calculating the time evolution
/// of these moments using various integration schemes.
///
/// - Author: Pascal Thibaudeau
/// - Date: 14/04/2023
/// - Update author: Mouad Fattouhi
/// - Updated: 11/09/2024
/// - Version: 0.1
public class Atom: Codable {
  /// Pre-allocated identity matrix for rhs() computations.
  private static let identityMatrix = Matrix3(fill: "identity")

  /// The name of the atomic species (e.g., "Fe", "Ni").
  public var name: String
  /// An identifier for the atomic type.
  public var type: Int
  /// The Landé factor of the atom (in units of Bohr magnetons).
  public var g: Double
  /// The Cartesian position of the atom in space.
  public var position: Vector3
  /// The atomic pulsation vector (field-like term).
  public var ω: Vector3
  /// The statistical moments of the spin.
  /// - `spin`: The first moment (average spin vector <S>).
  /// - `sigma`: The second moment (statistical cumulant <S*S>).
  public var moments: Moments

  /// A structure representing the first and second moments of spin dynamics.
  public struct Moments: Codable {
    /// The average spin vector <S>.
    public var spin: Vector3
    /// The statistical cumulant matrix <S*S>.
    public var sigma: Matrix3?

    /// Initializes the moments with optional spin and sigma values.
    /// - Parameters:
    ///   - spin: The average spin vector.
    ///   - sigma: The statistical cumulant matrix.
    public init(spin: Vector3 = Vector3(), sigma: Matrix3 = Matrix3()) {
      self.spin = spin
      self.sigma = sigma
    }

    /// Adds two sets of moments.
    static func + (a: Moments, b: Moments) -> Moments {
      return Moments(spin: (a.spin + b.spin), sigma: (a.sigma! + b.sigma!))
    }

    /// Adds a set of moments to another in-place.
    static func += (a: inout Moments, b: Moments) {
      a.spin += b.spin
      if a.sigma != nil && b.sigma != nil {
        a.sigma! += b.sigma!
      }
    }

    /// Scales a set of moments by a scalar value.
    static func * (a: Double, b: Moments) -> Moments {
      return Moments(spin: a * (b.spin), sigma: a * (b.sigma!))
    }
  }

  /// Initializes a new atom with specified properties.
  /// - Parameters:
  ///   - name: The name of the atom.
  ///   - type: The type identifier.
  ///   - position: The Cartesian position.
  ///   - ω: The initial pulsation vector.
  ///   - moments: The initial spin moments.
  ///   - g: The Landé factor (must be positive).
  public init(
    name: String = String(), type: Int = Int(), position: Vector3 = Vector3(),
    ω: Vector3 = Vector3(), moments: Moments = Moments(), g: Double = Double()
  ) {
    self.name = name
    self.type = type
    self.position = position
    self.ω = ω
    guard g >= 0 else { fatalError("g factor must be positive!") }
    self.g = g
    self.moments = moments
  }

  /// Computes the right-hand side (RHS) of the differential equations for the atomic spin moments.
  ///
  /// This function calculates the RHS of the coupled differential equations that describe the dynamics of the atomic spin first and second order cumulants. It uses the provided moments, temperature, damping factor, and thermostat type to compute the RHS.
  ///
  /// - Parameters:
  ///   - moments: The current moments of the atomic spin, including the spin vector and the sigma matrix.
  ///   - T: The temperature in Kelvin.
  ///   - α: The damping factor.
  ///   - thermostat: The type of thermostat used ("classical", "quantum2", or "quantum4"). Default is classical
  ///
  /// - Returns: A `Moments` object containing the computed RHS for the spin and sigma matrix.
  internal func rhs(
    moments: Moments, thermostat: Thermostat
  ) -> Moments {
    let α: Double = thermostat.α
    let c: Double = 1 / (1 + (α * α))
    let n: Double = g * μ_B.value
    let D: Double =
      γ.value * (α / n) * thermostat.computeThermalCoefficient()
    let spin: Vector3 = moments.spin
    let Σ: Matrix3 = moments.sigma!
    let traceOfΣ: Double = Σ.Trace()
    let transposeOfΣ: Matrix3 = Σ.Transpose()
    let Γ: Matrix3 = spin ⊗ spin
    let M: Matrix3 = ω ⊗ spin
    let I = Atom.identityMatrix

    var a1: Matrix3 = (traceOfΣ * M) - (transposeOfΣ * M)
    a1 += (M * transposeOfΣ) - (M.Trace() * transposeOfΣ)
    a1 += (M - M.Transpose()) * transposeOfΣ
    a1 -= 2 * ((Γ.Trace() * M) - (Γ.Transpose() * M))
    let m1: Matrix3 = (ω × transposeOfΣ) + (α * a1)
    let m2: Matrix3 = (2 * traceOfΣ * I) - (3 * (Σ + transposeOfΣ))

    var rhsdLLB: Moments = Atom.Moments()
    rhsdLLB.spin =
      c * ((ω × spin) + ((α * traceOfΣ * ω) - (α * transposeOfΣ * ω)) - (2 * D * c * spin))
    rhsdLLB.sigma = c * (m1 + (D * c * m2) + m1.Transpose())

    return rhsdLLB
  }

  /// Advances the atomic moments for a single time step using the requested numerical integration scheme.
  ///
  /// This function updates the `moments` property of the `Atom` instance by integrating the
  /// LLG (Landau-Lifshitz-Gilbert) equation or the dLLB (dynamic Landau-Lifshitz-Bloch) equations.
  ///
  /// - Parameters:
  ///   - method: The integration scheme. Supported methods:
  ///     "llg_euler" (explicit Euler),
  ///     "llg_symplectic" (second-order symplectic splitting),
  ///     "llg_symplecticf" (closed-form single spin rotation),
  ///     "dllb_euler" (explicit Euler for dLLB),
  ///     "dllb_rk4" (4th-order Runge-Kutta).
  ///   - Δt: The time step to advance the simulation.
  ///   - T: The temperature in Kelvin. Defaults to `0.0`.
  ///   - α: The damping factor. Defaults to `0.0`.
  ///   - thermostat: The type of thermostat used. Defaults to a classical thermostat.
  ///
  /// - Returns: None. The `moments` property is updated in-place.
  internal func advanceMoments(
    method: String,
    Δt: Double,
    thermostat: Thermostat = Thermostat()
  ) {
    switch method.lowercased() {
    case "llg_euler":
      self.moments.spin += Δt * (ω × self.moments.spin)
      self.moments.spin.normalized()
    case "llg_symplectic":
      let ω2: Double = ω ° ω
      let c: Double = 0.25 * Δt * Δt
      let c2: Double = 1.0 / (1.0 + c * ω2)
      let cross = Δt * (ω × self.moments.spin)
      let s1: Vector3 = c * ((2.0 * (ω ° self.moments.spin)) * ω - ω2 * self.moments.spin)
      self.moments.spin = c2 * (self.moments.spin + s1 + cross)
    case "llg_symplectic_full":
      let n: Double = ω.norm()
      let Ω: Vector3 = (1.0 / n) * ω
      let ξ: Double = n * Δt
      let χ: Double = Ω ° self.moments.spin
      let sinξ = sin(ξ)
      let cosξ = cos(ξ)
      self.moments.spin =
        cosξ * self.moments.spin + sinξ * (Ω × self.moments.spin) + (χ * (1.0 - cosξ)) * Ω
    case "llg_symplectic":
      var s: Vector3 = Vector3()
      let ω2: Double = ω ° ω
      let c: Double = 0.25 * Δt * Δt
      let c2: Double = 1.0 / (1.0 + c * ω2)
      var s1: Vector3 = c * ((2.0 * (ω ° moments.spin)) * ω - ω2 * moments.spin)
      s1 += Δt * (ω × moments.spin)
      s = c2 * (moments.spin + s1)
      self.moments.spin = s
    case "llg_symplectic_full":
      var s: Vector3 = Vector3()
      let n: Double = ω.norm()
      let Ω: Vector3 = (1.0 / n) * ω
      let ξ: Double = n * Δt
      let χ: Double = Ω ° (moments.spin)
      s = cos(ξ) * (moments.spin) + sin(ξ) * (Ω × (moments.spin)) + (χ * (1.0 - cos(ξ))) * Ω
      self.moments.spin = s
    case "dllb_euler":
      self.moments +=
        Δt * rhs(moments: self.moments, thermostat: thermostat)
    case "dllb_rk4":
      let k1: Atom.Moments = rhs(moments: self.moments, thermostat: thermostat)
      let k2: Atom.Moments = rhs(
        moments: self.moments + 0.5 * Δt * k1, thermostat: thermostat
      )
      let k3: Atom.Moments = rhs(
        moments: self.moments + 0.5 * Δt * k2, thermostat: thermostat
      )
      let k4: Atom.Moments = rhs(
        moments: self.moments + Δt * k3, thermostat: thermostat)
      self.moments += (Δt / 6) * (k1 + 2 * k2 + 2 * k3 + k4)
    default: break
    }
  }
  /// Serializes the atom into a JSON string.
  /// - Returns: A JSON string representation of the atom.
  /// - Throws: An error if encoding fails.
  internal func jsonify() throws -> String {
    let data: Data = try JSONEncoder().encode(self)
    if let jsonString: String = String(data: data, encoding: .utf8) {
      return jsonString
    } else {
      throw SpinswiftError.encodingError("Failed to convert data to JSON string")
    }
  }
}
