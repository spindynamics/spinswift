/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A class for integrating the dynamics of spin systems.
///
/// This class provides methods to evolve the state of a collection of atoms over time,
/// considering various magnetic interactions and thermal effects defined in an `Interaction` object.
///
/// - Author: Pascal Thibaudeau
/// - Date: 03/10/2023
/// - Update author: Mouad Fattouhi
/// - Updated: 11/09/2024
/// - Version: 0.1
public class Integrate: Codable {

  /// The interaction object containing the atoms and their magnetic environments.
  public var h: Interaction

  /// Initializes a new integrator with a specific interaction model.
  /// - Parameter h: The interaction model to use for the simulation.
  public init(_ h: Interaction = Interaction()) {
    self.h = h
  }

  /// Evolves the spin system over time using a specified integration method.
  ///
  /// This method performs a standard time-stepping loop, updating the moments of each atom
  /// and recording the total magnetization at each step.
  ///
  /// - Parameters:
  ///   - finalTime: The total duration of the simulation.
  ///   - Δt: The time step for each integration increment.
  ///   - method: The integration algorithm to use (e.g., "euler", "rk4").
  ///   - file: The filename to save the simulation results, or "NoFile" to skip saving.
  ///   - thermostat: The thermostat model to handle thermal fluctuations.
  public func evolve(
    finalTime: Double, Δt: Double, method: String, file: String, thermostat: Thermostat
  ) {
    var currentTime: Double = 0.0
    let analysis = Analysis(h.atoms)

    // Initialize streamer if a filename is provided
    var streamer: FileStreamer? = nil
    if file != "NoFile" {
      streamer = try? FileStreamer(fileName: file)
    }

    while currentTime < finalTime {
      for a: Atom in h.atoms {
        a.advanceMoments(method: method, Δt: Δt, thermostat: thermostat)
      }

      let summary = analysis.getMagnetizationSummary()
      let magnetizationVector = summary.vector
      let magnetizationNorm = summary.length

      if let streamer = streamer {
        let line =
          "\(currentTime) \(magnetizationVector.x) \(magnetizationVector.y) \(magnetizationVector.z) \(magnetizationNorm)"
        streamer.writeLine(line)
      }

      self.h.update()
      currentTime += Δt
    }

    streamer?.close()
  }

  /// Advances the dynamics of a collection of spins using symplectic splitting.
  ///
  /// This method uses a second-order symmetric splitting algorithm to maintain energy conservation
  /// for long-term integration of the spin dynamics. It handles field recalculations at each step.
  ///
  /// - Parameters:
  ///   - finalTime: The total time for the integration.
  ///   - Δt: The time step.
  ///   - method: The integration method for the moments (e.g., "llg_symplectic").
  ///   - file: Filename for the output data, or "NoFile" to skip saving.
  ///   - thermostat: The thermostat model for thermal noise.
  public func evolveSymplectic(
    finalTime: Double, Δt: Double, method: String, file: String, thermostat: Thermostat
  ) {
    var currentTime: Double = 0.0
    let analysis = Analysis(h.atoms)

    // Initialize streamer if a filename is provided
    var streamer: FileStreamer? = nil
    if file != "NoFile" {
      streamer = try? FileStreamer(fileName: file)
    }

    while currentTime < finalTime {
      for i in 0..<(h.atoms.count - 1) {
        h.update(index: i)
        h.atoms[i].advanceMoments(method: method, Δt: 0.5 * Δt, thermostat: thermostat)
      }
      h.update(index: h.atoms.count - 1)
      h.atoms[h.atoms.count - 1].advanceMoments(
        method: method, Δt: Δt, thermostat: thermostat)
      for i in stride(from: h.atoms.count - 2, through: 0, by: -1) {
        h.update(index: i)
        h.atoms[i].advanceMoments(method: method, Δt: 0.5 * Δt, thermostat: thermostat)
      }

      let summary = analysis.getMagnetizationSummary()
      let magnetizationVector = summary.vector
      let magnetizationNorm = summary.length

      if let streamer = streamer {
        let line =
          "\(currentTime) \(magnetizationVector.x) \(magnetizationVector.y) \(magnetizationVector.z) \(magnetizationNorm)"
        streamer.writeLine(line)
      }

      currentTime += Δt
    }

    streamer?.close()
  }

  /// Serializes the `Integrate` object into a JSON string.
  /// - Returns: A JSON-encoded string representation of the object.
  /// - Throws: An error if encoding fails.
  internal func jsonify() throws -> String {
    let data: Data = try JSONEncoder().encode(self)
    if let jsonString: String = String(data: data, encoding: .utf8) {
      return jsonString
    } else {
      throw SpinswiftError.encodingError("Failed to convert data to string")
    }
  }
}
