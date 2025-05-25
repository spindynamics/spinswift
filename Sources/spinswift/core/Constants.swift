/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A class for managing useful constants
///
/// - Author: Pascal Thibaudeau
/// - Date: 14/04/2023
/// - Version: 0.1

// a very small number
public let ε: Double = 1e-18

public struct PhysicalConstants: Codable {
    public let value: Double
    public let description: String
    public let units: String

    public init(value: Double, description: String, units: String) {
        self.value = value
        self.description = description
        self.units = units
    }

    public func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        if let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        } else {
            throw NSError(
                domain: "EncodingError", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON data to string"])
        }
    }
}
/// The elementary charge; e=1.602176634e-19 C
public let elementary_charge: PhysicalConstants = PhysicalConstants(
    value: 1.602176634e-19, description: "The elementary charge", units: "[A s]")
public let μ_B: PhysicalConstants = PhysicalConstants(
    value: 0.057883817555, description: "The Bohr Magneton", units: "[meV/T]")
public let μ_0: PhysicalConstants = PhysicalConstants(
    value: 2.0133545 * 1e-28, description: "The vacuum permeability", units: "[T^2 m^3 / meV]")
public let k_B: PhysicalConstants = PhysicalConstants(
    value: 0.08617330350, description: "The Boltzmann constant", units: "[meV/K]")
public let ℏ: PhysicalConstants = PhysicalConstants(
    value: 0.6582119514, description: "The Planck constant", units: "[meV*ps/rad]")

public let g_e: PhysicalConstants = PhysicalConstants(
    value: 2.00231930436182, description: "The electron (Landé) g-factor", units: "[unitless]")
public let γ: PhysicalConstants = PhysicalConstants(
    value: 0.1760859644, description: "The gyromagnetic ratio of electron", units: "[rad/(ps*T)]")

public typealias ConversionFactors = PhysicalConstants

public let mRy: ConversionFactors = ConversionFactors(
    value: 1.0 / 13.605693009, description: "milliRydberg", units: "[mRy/meV]")
public let erg: ConversionFactors = ConversionFactors(
    value: 6.2415091 * 1e14, description: "erg", units: "[erg/meV]")
public let Joule: ConversionFactors = ConversionFactors(
    value: 1e-3 / elementary_charge.value, description: "Joule", units: "[J/meV]")
