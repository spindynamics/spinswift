/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

/// A class for performing analysis on a system of atoms.
///
/// This class provides methods to calculate physical properties of the spin system,
/// such as total energy, magnetization, torque, temperature, and susceptibility.
class Analysis: Codable {

  /// The collection of atoms to analyze.
  let atoms: [Atom]

  /// Initializes a new analysis object with a collection of atoms.
  /// - Parameter atoms: An optional array of atoms. Defaults to an empty array.
  init(_ atoms: [Atom]? = nil) {
    self.atoms = atoms ?? []
  }

  /// Calculates the total energy of the system of atoms.
  ///
  /// This function iterates over all atoms in the system, summing up the
  /// dot product of the angular velocity (ω) and the spin moment for each atom.
  ///
  /// - Returns: A `Double` representing the total energy of the system.
  internal func getInstantEnergy() -> Double {
    var energy: Double = 0
    for atom in atoms {
      energy += (atom.ω ° atom.moments.spin)
    }
    return energy
  }

  /// Calculates the magnetization vector for the system of atoms.
  ///
  /// This function computes the weighted average of the spin moments,
  /// using the Landé factors (g) as weights.
  ///
  /// - Returns: A `Vector3` representing the magnetization vector of the system.
  internal func getMagnetization() -> Vector3 {
    var m = Vector3()
    var totalG: Double = 0
    for atom in atoms {
      let g = atom.g
      let spin = atom.moments.spin
      m.x += g * spin.x
      m.y += g * spin.y
      m.z += g * spin.z
      totalG += g
    }
    guard totalG != 0 else { return Vector3() }
    return (1.0 / totalG) * m
  }

  /// Calculates the average magnitude of the magnetization for the system.
  ///
  /// This function computes the average length of individual spin moments,
  /// weighted by their Landé factors (g).
  ///
  /// - Returns: A `Double` representing the average magnetization length.
  internal func getMagnetizationLength() -> Double {
    var mnorm: Double = 0
    var g: Double = 0
    for atom in atoms {
      mnorm += (atom.g * atom.moments.spin.norm())
      g += atom.g
    }
    guard g != 0 else { return 0 }
    return (1.0 / g) * mnorm
  }

  /// Calculates the magnetization vector and its average magnitude in a single pass.
  ///
  /// This method is optimized for performance in simulation loops by reducing
  /// data traversals and redundant calculations.
  ///
  /// - Returns: A tuple containing the magnetization vector and the average magnitude.
  internal func getMagnetizationSummary() -> (vector: Vector3, length: Double) {
    var vectorSumX: Double = 0
    var vectorSumY: Double = 0
    var vectorSumZ: Double = 0
    var magnitudeSum: Double = 0
    var totalG: Double = 0

    for atom in atoms {
      let g = atom.g
      let spin = atom.moments.spin

      // weighted spin vector: g * spin
      vectorSumX += g * spin.x
      vectorSumY += g * spin.y
      vectorSumZ += g * spin.z

      // weighted magnitude: g * |spin|
      magnitudeSum += g * spin.norm()

      totalG += g
    }

    guard totalG != 0 else { return (Vector3(), 0) }

    let invG = 1.0 / totalG
    return (
      Vector3(x: vectorSumX * invG, y: vectorSumY * invG, z: vectorSumZ * invG),
      magnitudeSum * invG
    )
  }

  /// Calculates the total torque acting on the system of atoms.
  ///
  /// This function sums the cross products of angular velocity (ω)
  /// and spin moment for each atom.
  ///
  /// - Returns: A `Vector3` representing the total torque vector.
  internal func getTorque() -> Vector3 {
    var torque = Vector3()
    for atom in atoms {
      torque += (atom.ω × atom.moments.spin)
    }
    return torque
  }

  /// Computes the spin temperature according to the Nurdin & Schotte model.
  ///
  /// See: [PhysRevE.61.3579](https://doi.org/10.1103/PhysRevE.61.3579)
  ///
  /// - Parameter coefficient: The thermal scaling coefficient, defaults to 2.0.
  /// - Returns: A `Double` representing the computed spin temperature.
  internal func getTemperature(coefficient: Double? = nil) -> Double {
    let e: Double = self.getInstantEnergy()
    let t: Vector3 = self.getTorque()
    let t2: Double = t ° t
    let T: Double = (t2 * ℏ.value) / (e * (coefficient ?? 2.0) * k_B.value)
    return T
  }

  /// Calculates the average magnetic susceptibility matrix for the system.
  ///
  /// The susceptibility is derived from the variance of the spin moments:
  /// χ = <Σ_i - S_i ⊗ S_i> / N.
  ///
  /// - Returns: A `Matrix3` representing the average magnetic susceptibility matrix.
  internal func getSusceptibility() -> Matrix3 {
    var χ: Matrix3 = Matrix3()
    var N: Double = 0
    for atom in atoms {
      let A: Matrix3 = (atom.moments.spin ⊗ atom.moments.spin)
      χ += atom.moments.sigma! - A
      N += 1
    }
    χ = (1 / N) * χ
    return χ
  }

  /// Calculates the average cumulant matrix for the system of atoms.
  ///
  /// Σ = <sigma_i> / N.
  ///
  /// - Returns: A `Matrix3` representing the average cumulant matrix.
  internal func getCumulant() -> Matrix3 {
    var Σ: Matrix3 = Matrix3()
    var N: Double = 0
    for atom in atoms {
      Σ += atom.moments.sigma!
      N += 1
    }
    Σ = (1 / N) * Σ
    return Σ
  }

  /// Computes all analysis values in a single pass for optimal performance.
  ///
  /// This method calculates energy, torque, magnetization (vector and length),
  /// susceptibility, and cumulant simultaneously, avoiding multiple iterations
  /// over the atoms array.
  ///
  /// - Returns: A tuple containing all analysis values computed in one pass.
  internal func getFullAnalysis() -> (
    energy: Double,
    torque: Vector3,
    magnetization: Vector3,
    magnetizationLength: Double,
    susceptibility: Matrix3,
    cumulant: Matrix3
  ) {
    var energy: Double = 0
    var torqueX: Double = 0
    var torqueY: Double = 0
    var torqueZ: Double = 0
    var mX: Double = 0
    var mY: Double = 0
    var mZ: Double = 0
    var magnitudeSum: Double = 0
    var totalG: Double = 0
    var χ: Matrix3 = Matrix3()
    var Σ: Matrix3 = Matrix3()
    var N: Double = 0

    for atom in atoms {
      let ω = atom.ω
      let spin = atom.moments.spin
      let g = atom.g
      let sigma = atom.moments.sigma!

      energy += (ω ° spin)

      torqueX += (ω.y * spin.z - ω.z * spin.y)
      torqueY += (ω.z * spin.x - ω.x * spin.z)
      torqueZ += (ω.x * spin.y - ω.y * spin.x)

      mX += g * spin.x
      mY += g * spin.y
      mZ += g * spin.z
      magnitudeSum += g * spin.norm()
      totalG += g

      let A = (spin ⊗ spin)
      χ += sigma - A
      Σ += sigma
      N += 1
    }

    let magnetization: Vector3
    let magnetizationLength: Double
    if totalG != 0 {
      magnetization = Vector3(
        x: (1.0 / totalG) * mX,
        y: (1.0 / totalG) * mY,
        z: (1.0 / totalG) * mZ
      )
      magnetizationLength = (1.0 / totalG) * magnitudeSum
    } else {
      magnetization = Vector3()
      magnetizationLength = 0
    }

    let susceptibility: Matrix3
    let cumulant: Matrix3
    if N != 0 {
      susceptibility = (1 / N) * χ
      cumulant = (1 / N) * Σ
    } else {
      susceptibility = Matrix3()
      cumulant = Matrix3()
    }

    let torque = Vector3(x: torqueX, y: torqueY, z: torqueZ)

    return (
      energy: energy,
      torque: torque,
      magnetization: magnetization,
      magnetizationLength: magnetizationLength,
      susceptibility: susceptibility,
      cumulant: cumulant
    )
  }
}
