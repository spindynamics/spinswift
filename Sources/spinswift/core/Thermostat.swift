/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A class representing a thermostat for atomic spin simulations.
///
/// This class manages properties and methods for calculating thermal coefficients
/// used in the dynamic Landau-Lifshitz-Bloch (dLLB) equation. It supports
/// classical and quantum thermostat models.
///
/// - Author: Pascal Thibaudeau
/// - Date: 14/04/2023
/// - Update author: Mouad Fattouhi
/// - Updated: 11/09/2024
/// - Version: 0.1
public class Thermostat: Codable {
  /// The type of thermostat (e.g., "classical", "quantum2", "quantum4").
  public var type: String
  /// The critical temperature (Curie temperature) in Kelvin.
  public var Tc: Double
  /// The characteristic magnon energy in meV.
  public var magnonEnergy: Double
  /// The atomic cell volume.
  public var cellVolume: Double
  /// The exchange stiffness at the critical temperature.
  public var exchangeStiffnessTc: Double
  /// The van Hove singularity of the magnon density of states.
  public var vanHoveSingularityDOS: Double
  /// The current temperature in Kelvin.
  public var T: Double
  /// The Gilbert damping parameter
  public var α: Double

  // MARK: - Internal Caching
  private var cachedT: Double?
  private var cachedValue: Double?

  private enum CodingKeys: String, CodingKey {
    case type, Tc, magnonEnergy, cellVolume, exchangeStiffnessTc, vanHoveSingularityDOS, T, α
  }

  /// Initializes a new thermostat with the given parameters.
  /// - Parameters:
  ///   - type: The type of thermostat.
  ///   - Tc: The critical temperature.
  ///   - magnonEnergy: The magnon energy.
  ///   - cellVolume: The atomic cell volume.
  ///   - exchangeStiffnessTc: The exchange stiffness at Tc.
  ///   - vanHoveSingularityDOS: The van Hove singularity of the DOS.
  ///   - T: The current temperature
  ///   - α: The Gilbert damping parameter
  public init(
    type: String = String(), Tc: Double? = Double(),
    magnonEnergy: Double? = Double(),
    cellVolume: Double? = Double(),
    exchangeStiffnessTc: Double? = Double(),
    vanHoveSingularityDOS: Double? = Double(),
    T: Double? = Double(),
    α: Double = Double()
  ) {
    self.type = type
    self.Tc = Tc!
    self.magnonEnergy = magnonEnergy!
    self.cellVolume = cellVolume!
    self.exchangeStiffnessTc = exchangeStiffnessTc!
    self.vanHoveSingularityDOS = vanHoveSingularityDOS!
    self.T = T!
    self.α = α
  }

  /// Computes the thermal coefficient for a given temperature.
  ///
  /// The coefficient is used to scale thermal noise in spin dynamics simulations.
  /// - Parameter T: The current temperature in Kelvin.
  /// - Returns: The calculated thermal coefficient.
  internal func computeThermalCoefficient() -> Double {
    // Return cached value if temperature hasn't changed
    if let cT = cachedT, let cV = cachedValue, cT == T {
      return cV
    }

    let result: Double
    switch self.type.lowercased() {
    case "classical":
      result = k_B.value * T
    case "quantum2":
      result = computeQFDR()
    case "quantum4":
      result = computeQFDRQuartic()
    default:
      result = 0.0
    }

    // Update cache
    cachedT = T
    cachedValue = result
    return result
  }

  /// Backend method for computing the Quantum Fluctuation-Dissipation Relation (QFDR).
  ///
  /// This method performs numerical integration of the density of states (DOS) weighted by the Bose-Einstein distribution.
  /// - Parameters:
  ///   - integrand: The function to integrate.
  ///   - scalingFactor: A scaling factor applied to the result of the integration.
  ///   - T: The current temperature in Kelvin.
  /// - Returns: The computed QFDR coefficient.
  internal func computeQFDRBackend(integrand: (Double) -> Double, scalingFactor: Double)
    -> Double
  {
    var coef: Double = 0
    if T >= Tc {
      coef = k_B.value * T
    } else {
      // Integrate from -1 to 1 using Gauss-Legendre
      let integral: Double = integrateGaussLegendre(
        function: integrand, lowerBound: -1, upperBound: 1)
      coef = scalingFactor * integral
    }
    return coef
  }

  /// Computes the QFDR using a quadratic magnon density of states (DOS).
  /// - Returns: The calculated thermal coefficient.
  internal func computeQFDR() -> Double {
    let β: Double = (k_B.value * T)
    let D0: Double = 1 - (T / Tc)
    let Ed: Double = magnonEnergy * pow(D0, 1 / 3)
    let u: Double = (Ed / β)

    // Create the simplest magnetic DOS as an integrand closure
    let integrand: (Double) -> Double = { (x: Double) -> Double in
      let xnew: Double = 0.5 * u * (x + 1)
      return pow(xnew, 1.5) / (exp(xnew) - 1)
    }

    // Apply scaling factors
    let scalingFactor: Double = 0.75 * Ed * pow(u, -1.5)

    // Use the backend method for integration
    return computeQFDRBackend(
      integrand: integrand,
      scalingFactor: scalingFactor
    )
  }

  /// Computes the QFDR using a quartic magnon density of states (DOS).
  /// - Returns: The calculated thermal coefficient.
  internal func computeQFDRQuartic() -> Double {
    let β: Double = (k_B.value * T)

    // Create the magnetic DOS as an integrand closure
    let integrand: (Double) -> Double = { (w: Double) -> Double in
      let innerValue1: Double =
        1 - ((4 * ℏ.value * w * self.vanHoveSingularityDOS) / self.exchangeStiffnessTc)
      guard innerValue1 > 0 else { return 0.0 }
      let sqrtInner: Double = innerValue1.squareRoot()

      let innerValue2: Double = (1 / (2 * self.vanHoveSingularityDOS)) * (1 - sqrtInner)
      guard innerValue2 >= 0 else { return 0.0 }

      let term1: Double = ℏ.value * w / (exp(ℏ.value * w / β) - 1)
      let term2: Double = innerValue2.squareRoot() / sqrtInner
      return term1 * term2
    }

    // Use the backend method for integration
    return computeQFDRBackend(integrand: integrand, scalingFactor: 1.0)
  }
}
