/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A class for managing useful constants
///
/// - Author: Pascal Thibaudeau
/// - Date: 14/04/2023
/// - Update author: Mouad Fattouhi
/// - Date: 30/09/2025
/// - Version: 0.1

/// A very small number used for numerical stability.
public let ε: Double = 1e-18

/// The mathematical constant PI.
public let π: Double = Double.pi

/// A structure representing a physical constant with its value, description, and units.
public struct PhysicalConstants: Codable, Sendable {
  /// The numerical value of the constant.
  public let value: Double
  /// A brief description of the constant.
  public let description: String
  /// The units of the constant.
  public let units: String

  /// Initializes a new physical constant.
  /// - Parameters:
  ///   - value: The numerical value.
  ///   - description: A description of the constant.
  ///   - units: The units of the constant.
  public init(value: Double, description: String, units: String) {
    self.value = value
    self.description = description
    self.units = units
  }

  /// Serializes the constant into a JSON string.
  /// - Returns: A JSON string representation of the constant.
  /// - Throws: An error if encoding fails.
  public func jsonify() throws -> String {
    let data: Data = try JSONEncoder().encode(self)
    if let jsonString: String = String(data: data, encoding: .utf8) {
      return jsonString
    } else {
      throw SpinswiftError.encodingError("Failed to convert JSON data to string")
    }
  }
}

/// The elementary charge (e ≈ 1.602 x 10^-19 C).
public let elementary_charge: PhysicalConstants = PhysicalConstants(
  value: 1.602176634e-19, description: "The elementary charge", units: "[A s]")

/// The Bohr Magneton (μ_B ≈ 0.0579 meV/T).
public let μ_B: PhysicalConstants = PhysicalConstants(
  value: 0.057883817555, description: "The Bohr Magneton", units: "[meV/T]")

/// The vacuum permeability (μ_0).
public let μ_0: PhysicalConstants = PhysicalConstants(
  value: 2.0133545 * 1e-28, description: "The vacuum permeability", units: "[T^2 m^3 / meV]")

/// The Boltzmann constant (k_B ≈ 0.0862 meV/K).
public let k_B: PhysicalConstants = PhysicalConstants(
  value: 0.08617330350, description: "The Boltzmann constant", units: "[meV/K]")

/// The reduced Planck constant (ℏ ≈ 0.6582 meV*ps/rad).
public let ℏ: PhysicalConstants = PhysicalConstants(
  value: 0.6582119514, description: "The Planck constant", units: "[meV*ps/rad]")

/// The electron (Landé) g-factor.
public let g_e: PhysicalConstants = PhysicalConstants(
  value: 2.00231930436182, description: "The electron (Landé) g-factor", units: "[unitless]")

/// The gyromagnetic ratio of the electron (γ ≈ 0.1761 rad/(ps*T)).
public let γ: PhysicalConstants = PhysicalConstants(
  value: 0.1760859644, description: "The gyromagnetic ratio of electron", units: "[rad/(ps*T)]")

/// A type alias for physical constants used as conversion factors.
public typealias ConversionFactors = PhysicalConstants

/// Conversion factor for milliRydberg.
public let mRy: ConversionFactors = ConversionFactors(
  value: 1.0 / 13.605693009, description: "milliRydberg", units: "[mRy/meV]")

/// Conversion factor for erg.
public let erg: ConversionFactors = ConversionFactors(
  value: 6.2415091 * 1e14, description: "erg", units: "[erg/meV]")

/// Conversion factor for Joule.
public let Joule: ConversionFactors = ConversionFactors(
  value: 1e3 / elementary_charge.value, description: "Joule", units: "[J/meV]")
