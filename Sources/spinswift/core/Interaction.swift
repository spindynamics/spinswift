/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A class for managing interactions between the atoms
///
/// Interactions act between atoms.
/// - Author: Pascal Thibaudeau
/// - Date: 14/04/2023
/// - Update author: Mouad Fattouhi
/// - Updated: 01/09/2024
/// - Version: 0.1
public class Interaction: Codable {

  public var atoms: [Atom]

  public struct Zeeman: Codable {
    var computed: Bool = false
    var axis: Vector3 = Vector3()
    var value: Double = Double()
  }
  public struct SpinTransferTorque: Codable {
    /// true or false if the spin transfer torque is computed
    var computed: Bool = false
    var polarization: Vector3 = Vector3()
    var fieldLikeAmplitude: Double = Double()
    var dampingLikeAmplitude: Double = Double()
  }
  public struct Exchange: Codable {
    /// true or false if the exchange is computed
    var computed: Bool = false
    var typeI: Int = Int()
    var typeJ: Int = Int()
    var value: Double = Double()
    var cutoffRadius: Double = Double()
    var boundaryConditions: BoundaryConditions = BoundaryConditions()
  }
  /// Manages the Dzyaloshinskii-Moriya Interaction (DMI).
  public struct DMI: Codable {
    /// True if the DMI field is computed
    var computed: Bool = false
    var value: Double = Double()
    var typeI: Int = Int()
    var typeJ: Int = Int()
    var cutoffRadius: Double = Double()
    var boundaryConditions: BoundaryConditions = BoundaryConditions()
  }
  /// Manages the damping field.
  public struct Damping: Codable {
    /// True if the damping field is computed
    var computed: Bool = false
    var α: Double = Double()
  }
  /// Manages the uniaxial anisotropy field.
  public struct Uniaxial: Codable {
    /// True if the uniaxial anisotropy field is computed
    var computed: Bool = false
    var axis: Vector3 = Vector3()
    var value: Double = Double()
  }
  /// Manages the uniform demagnetizing field.
  public struct Demagnetizing: Codable {
    /// True if the uniform demagnetizing field is computed
    var computed: Bool = false
    /// 3 values such that n[1]+n[2]+n[3]=1
    var n: Vector3 = Vector3()
  }
  /// Manages the stochastic field (thermal field).
  public struct Stochastic: Codable {
    /// True if the stochastic (thermal) field is computed
    var computed: Bool = false
    var thermostat: Thermostat = Thermostat()
    var Δt: Double = Double()
  }

  internal var zeemanConfig = Zeeman()
  internal var sttConfig = SpinTransferTorque()
  internal var exchangeConfig = Exchange()
  internal var dmiConfig = DMI()
  internal var dampingConfig = Damping()
  internal var uniaxialConfig = Uniaxial()
  internal var demagConfig = Demagnetizing()
  internal var stochasticConfig = Stochastic()

  /// Caches for performance optimization
  private var atomNeighbors: [[Int]] = []
  private var staticFields: [Vector3] = []
  private var needsNeighborRebuild: Bool = true
  private var needsStaticFieldUpdate: Bool = true

  private enum CodingKeys: String, CodingKey {
    case atoms, zeemanConfig, sttConfig, exchangeConfig, dmiConfig, dampingConfig, uniaxialConfig,
      demagConfig, stochasticConfig
  }

  /// Initializes a new Interaction instance with the provided atoms.
  ///
  /// This initializer creates an interaction manager for a collection of atoms
  /// and resets the angular frequency (ω) vector to zero for all atoms.
  ///
  /// - Parameters:
  ///   - atoms: An array of atoms to manage interactions for. Defaults to an empty array.
  ///
  /// - Returns: A new Interaction instance.
  public init(_ atoms: [Atom] = []) {
    self.atoms = atoms
    for atom in atoms {
      atom.ω = Vector3()
    }
  }

  /// Rebuilds neighbor lists for all atoms based on cutoff radii.
  public func rebuildNeighborLists() {
    let count = atoms.count
    atomNeighbors = Array(repeating: [], count: count)

    // Determine the maximum cutoff radius among active interactions
    var maxCutoff: Double = 0
    if exchangeConfig.computed { maxCutoff = max(maxCutoff, exchangeConfig.cutoffRadius) }
    if dmiConfig.computed { maxCutoff = max(maxCutoff, dmiConfig.cutoffRadius) }

    let cutoffSq = maxCutoff * maxCutoff
    guard cutoffSq > 0 else {
      needsNeighborRebuild = false
      return
    }

    let bcs =
      exchangeConfig.computed ? exchangeConfig.boundaryConditions : dmiConfig.boundaryConditions
    let usePBC = bcs.PBC.lowercased() == "on"
    let box = bcs.BoxSize

    for i in 0..<count {
      let posI = atoms[i].position
      for j in (i + 1)..<count {
        let posJ = atoms[j].position
        var dx = posJ.x - posI.x
        var dy = posJ.y - posI.y
        var dz = posJ.z - posI.z

        if usePBC {
          dx -= box.x * (dx / box.x).rounded(.toNearestOrAwayFromZero)
          dy -= box.y * (dy / box.y).rounded(.toNearestOrAwayFromZero)
          dz -= box.z * (dz / box.z).rounded(.toNearestOrAwayFromZero)
        }

        if dx * dx + dy * dy + dz * dz <= cutoffSq {
          atomNeighbors[i].append(j)
          atomNeighbors[j].append(i)
        }
      }
    }
    needsNeighborRebuild = false
  }

  /// Updates cached static fields (Zeeman, STT polarization).
  private func updateStaticFields() {
    let count = atoms.count
    staticFields = Array(repeating: Vector3(), count: count)

    let gamma = γ.value

    let zComputed = zeemanConfig.computed
    let zCoeff = gamma * zeemanConfig.value
    let zAxis = zeemanConfig.axis

    // Stochastic field is technically "dynamic" but if we want to pre-calculate its constant part
    // it's tricky because it uses random numbers. We'll handle it in the dynamic update.

    guard zComputed else {
      needsStaticFieldUpdate = false
      return
    }

    for i in 0..<count {
      var omega = Vector3()

      if zComputed {
        omega.x += zCoeff * zAxis.x
        omega.y += zCoeff * zAxis.y
        omega.z += zCoeff * zAxis.z
      }

      staticFields[i] = omega
    }
    needsStaticFieldUpdate = false
  }

  /// Applies Gilbert damping to the effective field acting on all atoms.
  ///
  /// This method modifies the angular frequency (ω) of each atom by applying the
  /// Gilbert damping term, which introduces energy dissipation in the spin dynamics.
  /// The damping is described by: ``ω' = (ω + α(m × ω)) / (1 + α²)``
  ///
  /// - Parameters:
  ///   - value: The Gilbert damping parameter (α), typically between 0 and 1.
  ///
  /// - Returns: The Interaction instance for method chaining.
  ///
  /// - Important: This field must be applied last in the chain, after all other fields.
  @discardableResult
  public func dampingField(_ value: Double) -> Interaction {
    let coeff = 1.0 / (1.0 + value * value)
    for atom in self.atoms {
      let spin = atom.moments.spin
      var ω = atom.ω

      // Temp storage for cross product (m x ω) to avoid allocations
      let tx = spin.y * ω.z - spin.z * ω.y
      let ty = spin.z * ω.x - spin.x * ω.z
      let tz = spin.x * ω.y - spin.y * ω.x

      ω.x = coeff * (ω.x + value * tx)
      ω.y = coeff * (ω.y + value * ty)
      ω.z = coeff * (ω.z + value * tz)
      atom.ω = ω
    }
    self.dampingConfig = Damping(computed: true, α: value)
    return self
  }

  /// Adds the demagnetizing field contribution to the effective field.
  ///
  /// This method computes the demagnetizing field arising from dipolar interactions
  /// within the magnetic sample. The demagnetizing field is given by: ``H_demag = -N·M``
  /// where N is the demagnetizing tensor with diagonal elements (nx, ny, nz).
  ///
  /// - Parameters:
  ///   - n: Demagnetizing factor vector along (x, y, z).
  ///
  /// - Returns: The Interaction instance for method chaining.
  ///
  /// - Precondition: The sum n.x + n.y + n.z must equal 1.
  @discardableResult
  public func demagnetizingField(n: Vector3) -> Interaction {
    assert(
      abs(n.x + n.y + n.z - 1.0) < 1e-9, "Demagnetizing: the sum of the coefficients should be 1")
    for atom in self.atoms {
      let spin = atom.moments.spin
      atom.ω.x -= n.x * spin.x
      atom.ω.y -= n.y * spin.y
      atom.ω.z -= n.z * spin.z
    }
    self.demagConfig = Demagnetizing(computed: true, n: n)
    return self
  }

  /// Adds the exchange field contribution to the effective field.
  ///
  /// This method computes the Heisenberg exchange interaction between neighboring spins.
  /// The exchange energy is given by: ``E = -J Σ S_i · S_j``
  /// where the sum is over neighboring pairs within the cutoff radius.
  ///
  /// - Parameters:
  ///   - typeI: The atomic type of the first species.
  ///   - typeJ: The atomic type of the second species.
  ///   - value: The exchange coupling constant J.
  ///   - cutoffRadius: The maximum distance between atoms for exchange coupling.
  ///   - boundaryConditions: Periodic or open boundary conditions.
  @discardableResult
  public func exchangeField(
    typeI: Int, typeJ: Int, value: Double, cutoffRadius: Double,
    boundaryConditions: BoundaryConditions
  ) -> Interaction {
    needsNeighborRebuild = true
    let atomCount = atoms.count
    let gamma = γ.value
    let muB = μ_B.value
    let rValue = gamma * value
    let cutoffSq = cutoffRadius * cutoffRadius

    let usePBC = boundaryConditions.PBC.lowercased() == "on"
    let box = boundaryConditions.BoxSize

    for i in 0..<atomCount {
      let atomI = atoms[i]
      let isITypeI = atomI.type == typeI
      let isITypeJ = atomI.type == typeJ
      guard isITypeI || isITypeJ else { continue }

      let posI = atomI.position
      let f1 = atomI.g * muB

      for j in (i + 1)..<atomCount {
        let atomJ = atoms[j]
        let isJTypeI = atomJ.type == typeI
        let isJTypeJ = atomJ.type == typeJ

        // Check for (typeI, typeJ) or (typeJ, typeI) pair
        guard (isITypeI && isJTypeJ) || (isITypeJ && isJTypeI) else { continue }

        let posJ = atomJ.position
        var dx = posJ.x - posI.x
        var dy = posJ.y - posI.y
        var dz = posJ.z - posI.z

        if usePBC {
          dx -= box.x * (dx / box.x).rounded(.toNearestOrAwayFromZero)
          dy -= box.y * (dy / box.y).rounded(.toNearestOrAwayFromZero)
          dz -= box.z * (dz / box.z).rounded(.toNearestOrAwayFromZero)
        }

        let distSq = dx * dx + dy * dy + dz * dz
        if distSq <= cutoffSq {
          let f2 = atomJ.g * muB
          let spinI = atomI.moments.spin
          let spinJ = atomJ.moments.spin

          let coeffI = rValue / f1
          atomI.ω.x += coeffI * spinJ.x
          atomI.ω.y += coeffI * spinJ.y
          atomI.ω.z += coeffI * spinJ.z

          let coeffJ = rValue / f2
          atomJ.ω.x += coeffJ * spinI.x
          atomJ.ω.y += coeffJ * spinI.y
          atomJ.ω.z += coeffJ * spinI.z
        }
      }
    }

    self.exchangeConfig = Interaction.Exchange(
      computed: true, typeI: typeI, typeJ: typeJ, value: value, cutoffRadius: cutoffRadius,
      boundaryConditions: boundaryConditions)
    return self
  }

  /// Adds the Dzyaloshinskii-Moriya Interaction (DMI) field contribution.
  ///
  /// - Parameters:
  ///   - typeI: The atomic type of the first species.
  ///   - typeJ: The atomic type of the second species.
  ///   - value: The DMI coupling constant D.
  ///   - cutoffRadius: The maximum distance for DMI coupling.
  ///   - boundaryConditions: Periodic or open boundary conditions.
  @discardableResult
  public func dmiField(
    typeI: Int, typeJ: Int, value: Double, cutoffRadius: Double,
    boundaryConditions: BoundaryConditions
  ) -> Interaction {
    needsNeighborRebuild = true
    let atomCount = atoms.count
    let gamma = γ.value
    let muB = μ_B.value
    let cutoffSq = cutoffRadius * cutoffRadius

    let usePBC = boundaryConditions.PBC.lowercased() == "on"
    let box = boundaryConditions.BoxSize

    for i in 0..<atomCount {
      let atomI = atoms[i]
      let isITypeI = atomI.type == typeI
      let isITypeJ = atomI.type == typeJ
      guard isITypeI || isITypeJ else { continue }

      let posI = atomI.position
      let f1 = atomI.g * muB

      for j in (i + 1)..<atomCount {
        let atomJ = atoms[j]
        let isJTypeI = atomJ.type == typeI
        let isJTypeJ = atomJ.type == typeJ

        guard (isITypeI && isJTypeJ) || (isITypeJ && isJTypeI) else { continue }

        let posJ = atomJ.position
        var dx = posJ.x - posI.x
        var dy = posJ.y - posI.y
        var dz = posJ.z - posI.z

        if usePBC {
          dx -= box.x * (dx / box.x).rounded(.toNearestOrAwayFromZero)
          dy -= box.y * (dy / box.y).rounded(.toNearestOrAwayFromZero)
          dz -= box.z * (dz / box.z).rounded(.toNearestOrAwayFromZero)
        }

        let distSq = dx * dx + dy * dy + dz * dz
        if distSq <= cutoffSq {
          let f2 = atomJ.g * muB
          let dist = distSq.squareRoot()
          let spinI = atomI.moments.spin
          let spinJ = atomJ.moments.spin

          // Normalized D vector: D_ij = value * (posJ - posI) / dist
          // If we had (isITypeJ && isJTypeI), the vector direction should be swapped
          let sign: Double = isITypeI ? 1.0 : -1.0
          let dix = sign * value * dx / dist
          let diy = sign * value * dy / dist
          let diz = sign * value * dz / dist

          // Field I: (gamma / F1) * (D_ij x S_j)
          let coeffI = gamma / f1
          atomI.ω.x += coeffI * ((diy * spinJ.z) - (diz * spinJ.y))
          atomI.ω.y += coeffI * ((diz * spinJ.x) - (dix * spinJ.z))
          atomI.ω.z += coeffI * ((dix * spinJ.y) - (diy * spinJ.x))

          // Field J: (gamma / F2) * (-D_ij x S_i) = (gamma / F2) * (S_i x D_ij)
          let coeffJ = gamma / f2
          atomJ.ω.x += coeffJ * ((spinI.y * diz) - (spinI.z * diy))
          atomJ.ω.y += coeffJ * ((spinI.z * dix) - (spinI.x * diz))
          atomJ.ω.z += coeffJ * ((spinI.x * diy) - (spinI.y * dix))
        }
      }
    }

    self.dmiConfig = Interaction.DMI(
      computed: true, value: value, typeI: typeI, typeJ: typeJ, cutoffRadius: cutoffRadius,
      boundaryConditions: boundaryConditions)
    return self
  }

  /// Adds the uniaxial anisotropy field contribution to the effective field.
  ///
  /// - Parameters:
  ///   - axis: The easy axis direction.
  ///   - value: The anisotropy constant K.
  @discardableResult
  public func uniaxialField(_ axis: Vector3, value: Double) -> Interaction {
    let coeff = (γ.value * value) / μ_B.value
    for atom in atoms {
      let spin = atom.moments.spin
      let dot = spin.x * axis.x + spin.y * axis.y + spin.z * axis.z
      let factor = (coeff / atom.g) * dot
      atom.ω.x += factor * axis.x
      atom.ω.y += factor * axis.y
      atom.ω.z += factor * axis.z
    }
    self.uniaxialConfig = Uniaxial(computed: true, axis: axis, value: value)
    return self
  }

  /// Adds the Zeeman field contribution to the effective field.
  ///
  /// - Parameters:
  ///   - axis: The direction of the external magnetic field.
  ///   - value: The magnitude of the external field.
  @discardableResult
  public func zeemanField(_ axis: Vector3, value: Double) -> Interaction {
    needsStaticFieldUpdate = true
    let coeff = γ.value * value
    for atom in atoms {
      atom.ω.x += coeff * axis.x
      atom.ω.y += coeff * axis.y
      atom.ω.z += coeff * axis.z
    }
    self.zeemanConfig = Zeeman(computed: true, axis: axis, value: value)
    return self
  }

  /// Adds the spin transfer torque (STT) term to the effective field.
  ///
  /// - Parameters:
  ///   - polarization: The spin polarization direction.
  ///   - fieldLikeAmplitude: Strength of the field-like STT.
  ///   - dampingLikeAmplitude: Strength of the damping-like STT.
  @discardableResult
  public func spinTransferTorqueField(
    polarization: Vector3, fieldLikeAmplitude: Double, dampingLikeAmplitude: Double
  ) -> Interaction {
    needsStaticFieldUpdate = true
    for atom in atoms {
      let spin = atom.moments.spin
      // torque = spin x polarization
      let tx = spin.y * polarization.z - spin.z * polarization.y
      let ty = spin.z * polarization.x - spin.x * polarization.z
      let tz = spin.x * polarization.y - spin.y * polarization.x

      atom.ω.x += fieldLikeAmplitude * tx
      atom.ω.y += fieldLikeAmplitude * ty
      atom.ω.z += fieldLikeAmplitude * tz

      // damping-like torque = spin x torque
      atom.ω.x += dampingLikeAmplitude * (spin.y * tz - spin.z * ty)
      atom.ω.y += dampingLikeAmplitude * (spin.z * tx - spin.x * tz)
      atom.ω.z += dampingLikeAmplitude * (spin.x * ty - spin.y * tx)
    }
    self.sttConfig = SpinTransferTorque(
      computed: true, polarization: polarization, fieldLikeAmplitude: fieldLikeAmplitude,
      dampingLikeAmplitude: dampingLikeAmplitude)
    return self
  }

  @discardableResult
  public func stochasticField(thermostat: Thermostat, Δt: Double) -> Interaction {

    let c = (2.0 * π * thermostat.α * thermostat.computeThermalCoefficient() / (ℏ.value * Δt))
      .squareRoot()

    for atom in atoms {
      atom.ω.x += c * Double.random(in: -1...1)
      atom.ω.y += c * Double.random(in: -1...1)
      atom.ω.z += c * Double.random(in: -1...1)
    }
    self.stochasticConfig = Stochastic(
      computed: true, thermostat: thermostat, Δt: Δt)
    return self
  }

  /// Updates all effective fields based on previously configured interactions.
  public func update() {
    if needsNeighborRebuild { rebuildNeighborLists() }
    if needsStaticFieldUpdate { updateStaticFields() }

    // Reset and apply static/local fields
    for i in 0..<atoms.count {
      let atom = atoms[i]
      atom.ω = staticFields[i]
    }

    // Apply other local fields (Uniaxial, Demag, STT, Stochastic)
    applyLocalFields()

    // Apply non-local (pair) fields using neighbor lists
    if exchangeConfig.computed || dmiConfig.computed {
      let gamma = γ.value
      let muB = μ_B.value

      let typeI_E = exchangeConfig.typeI
      let typeJ_E = exchangeConfig.typeJ
      let rValue_E = gamma * exchangeConfig.value

      let typeI_D = dmiConfig.typeI
      let typeJ_D = dmiConfig.typeJ
      let val_D = dmiConfig.value

      let bcs =
        exchangeConfig.computed ? exchangeConfig.boundaryConditions : dmiConfig.boundaryConditions
      let usePBC = bcs.PBC.lowercased() == "on"
      let box = bcs.BoxSize

      let exchangeCutoffSq = exchangeConfig.cutoffRadius * exchangeConfig.cutoffRadius
      let dmiCutoffSq = dmiConfig.cutoffRadius * dmiConfig.cutoffRadius

      for i in 0..<atoms.count {
        let atomI = atoms[i]
        let posI = atomI.position
        let f1 = atomI.g * muB
        let isITypeI_E = atomI.type == typeI_E
        let isITypeJ_E = atomI.type == typeJ_E
        let isITypeI_D = atomI.type == typeI_D
        let isITypeJ_D = atomI.type == typeJ_D

        for j in atomNeighbors[i] {
          // Since neighbor lists are symmetric, we only process j > i to avoid double counting
          // Wait, update() usually overwrites atom.ω.
          // If we want to use the same symmetric logic as before, we need to be careful.
          // The previous exchangeField(typeI:typeJ:...) loop was:
          // for i in 0..<atomCount { ... for j in (i+1)..<atomCount { ... } }
          // And it added to BOTH atomI.ω and atomJ.ω.
          guard j > i else { continue }

          let atomJ = atoms[j]
          let posJ = atomJ.position
          var dx = posJ.x - posI.x
          var dy = posJ.y - posI.y
          var dz = posJ.z - posI.z

          if usePBC {
            dx -= box.x * (dx / box.x).rounded(.toNearestOrAwayFromZero)
            dy -= box.y * (dy / box.y).rounded(.toNearestOrAwayFromZero)
            dz -= box.z * (dz / box.z).rounded(.toNearestOrAwayFromZero)
          }

          let distSq = dx * dx + dy * dy + dz * dz

          // Exchange
          if exchangeConfig.computed && distSq <= exchangeCutoffSq {
            let isJTypeI = atomJ.type == typeI_E
            let isJTypeJ = atomJ.type == typeJ_E
            if (isITypeI_E && isJTypeJ) || (isITypeJ_E && isJTypeI) {
              let f2 = atomJ.g * muB
              let spinI = atomI.moments.spin
              let spinJ = atomJ.moments.spin

              atomI.ω.x += (rValue_E / f1) * spinJ.x
              atomI.ω.y += (rValue_E / f1) * spinJ.y
              atomI.ω.z += (rValue_E / f1) * spinJ.z

              atomJ.ω.x += (rValue_E / f2) * spinI.x
              atomJ.ω.y += (rValue_E / f2) * spinI.y
              atomJ.ω.z += (rValue_E / f2) * spinI.z
            }
          }

          // DMI
          if dmiConfig.computed && distSq <= dmiCutoffSq {
            let isJTypeI = atomJ.type == typeI_D
            let isJTypeJ = atomJ.type == typeJ_D
            if (isITypeI_D && isJTypeJ) || (isITypeJ_D && isJTypeI) {
              let f2 = atomJ.g * muB
              let dist = distSq.squareRoot()
              let spinI = atomI.moments.spin
              let spinJ = atomJ.moments.spin

              let sign: Double = isITypeI_D ? 1.0 : -1.0
              let dix = sign * val_D * dx / dist
              let diy = sign * val_D * dy / dist
              let diz = sign * val_D * dz / dist

              // Field I
              atomI.ω.x += (gamma / f1) * (diy * spinJ.z - diz * spinJ.y)
              atomI.ω.y += (gamma / f1) * (diz * spinJ.x - dix * spinJ.z)
              atomI.ω.z += (gamma / f1) * (dix * spinJ.y - diy * spinJ.x)

              // Field J
              atomJ.ω.x += (gamma / f2) * (spinI.y * diz - spinI.z * diy)
              atomJ.ω.y += (gamma / f2) * (spinI.z * dix - spinI.x * diz)
              atomJ.ω.z += (gamma / f2) * (spinI.x * diy - spinI.y * dix)
            }
          }
        }
      }
    }

    // 3. Damping must be applied last
    if dampingConfig.computed {
      dampingField(dampingConfig.α)
    }
  }

  /// Internal helper to apply all local fields in a single pass over atoms.
  private func applyLocalFields() {
    let gamma = γ.value
    let muB = μ_B.value

    let zComputed = zeemanConfig.computed
    let zCoeff = gamma * zeemanConfig.value
    let zAxis = zeemanConfig.axis

    let uComputed = uniaxialConfig.computed
    let uCoeff = (gamma * uniaxialConfig.value) / muB
    let uAxis = uniaxialConfig.axis

    let dComputed = demagConfig.computed
    let dn = demagConfig.n

    let sComputed = sttConfig.computed
    let sPol = sttConfig.polarization
    let sField = sttConfig.fieldLikeAmplitude
    let sDamp = sttConfig.dampingLikeAmplitude

    let stComputed = stochasticConfig.computed
    let stThermostat = stochasticConfig.thermostat
    let stΔt = stochasticConfig.Δt

    // Only iterate if at least one local field is active
    guard zComputed || uComputed || dComputed || sComputed || stComputed else { return }

    let c = (2.0 * π * stThermostat.α * stThermostat.computeThermalCoefficient() / (ℏ.value * stΔt))
      .squareRoot()

    for atom in atoms {
      let spin = atom.moments.spin
      var omega = atom.ω

      if zComputed {
        omega.x += zCoeff * zAxis.x
        omega.y += zCoeff * zAxis.y
        omega.z += zCoeff * zAxis.z
      }

      if uComputed {
        let dot = spin.x * uAxis.x + spin.y * uAxis.y + spin.z * uAxis.z
        let factor = (uCoeff / atom.g) * dot
        omega.x += factor * uAxis.x
        omega.y += factor * uAxis.y
        omega.z += factor * uAxis.z
      }

      if dComputed {
        omega.x -= dn.x * spin.x
        omega.y -= dn.y * spin.y
        omega.z -= dn.z * spin.z
      }

      if sComputed {
        let tx = spin.y * sPol.z - spin.z * sPol.y
        let ty = spin.z * sPol.x - spin.x * sPol.z
        let tz = spin.x * sPol.y - spin.y * sPol.x

        omega.x += sField * tx
        omega.y += sField * ty
        omega.z += sField * tz

        omega.x += sDamp * (spin.y * tz - spin.z * ty)
        omega.y += sDamp * (spin.z * tx - spin.x * tz)
        omega.z += sDamp * (spin.x * ty - spin.y * tx)
      }

      if stComputed {
        omega.x += c * Double.random(in: -1...1)
        omega.y += c * Double.random(in: -1...1)
        omega.z += c * Double.random(in: -1...1)
      }
      atom.ω = omega
    }
  }

  /// Updates the effective field for a specific atom using cached neighbors and static fields.
  public func update(index: Int) {
    if needsNeighborRebuild { rebuildNeighborLists() }
    if needsStaticFieldUpdate { updateStaticFields() }

    let atom = atoms[index]
    let spin = atom.moments.spin
    var omega = staticFields[index]

    let gamma = γ.value
    let muB = μ_B.value

    if sttConfig.computed {
      let pol = sttConfig.polarization
      let tx = spin.y * pol.z - spin.z * pol.y
      let ty = spin.z * pol.x - spin.x * pol.z
      let tz = spin.x * pol.y - spin.y * pol.x

      omega.x += sttConfig.fieldLikeAmplitude * tx
      omega.y += sttConfig.fieldLikeAmplitude * ty
      omega.z += sttConfig.fieldLikeAmplitude * tz

      omega.x += sttConfig.dampingLikeAmplitude * (spin.y * tz - spin.z * ty)
      omega.y += sttConfig.dampingLikeAmplitude * (spin.z * tx - spin.x * tz)
      omega.z += sttConfig.dampingLikeAmplitude * (spin.x * ty - spin.y * tx)
    }

    if exchangeConfig.computed || dmiConfig.computed {
      let typeI_E = exchangeConfig.typeI
      let typeJ_E = exchangeConfig.typeJ
      let rValue_E = gamma * exchangeConfig.value
      let isITypeI_E = atom.type == typeI_E
      let isITypeJ_E = atom.type == typeJ_E

      let typeI_D = dmiConfig.typeI
      let typeJ_D = dmiConfig.typeJ
      let val_D = dmiConfig.value
      let isITypeI_D = atom.type == typeI_D
      let isITypeJ_D = atom.type == typeJ_D

      let f1 = atom.g * muB
      let coeff_E = rValue_E / f1
      let coeff_D = gamma / f1

      let bcs =
        exchangeConfig.computed ? exchangeConfig.boundaryConditions : dmiConfig.boundaryConditions
      let usePBC = bcs.PBC.lowercased() == "on"
      let box = bcs.BoxSize
      let posI = atom.position

      let exchangeCutoffSq = exchangeConfig.cutoffRadius * exchangeConfig.cutoffRadius
      let dmiCutoffSq = dmiConfig.cutoffRadius * dmiConfig.cutoffRadius

      for j in atomNeighbors[index] {
        let atomJ = atoms[j]
        let posJ = atomJ.position
        var dx = posJ.x - posI.x
        var dy = posJ.y - posI.y
        var dz = posJ.z - posI.z

        if usePBC {
          dx -= box.x * (dx / box.x).rounded(.toNearestOrAwayFromZero)
          dy -= box.y * (dy / box.y).rounded(.toNearestOrAwayFromZero)
          dz -= box.z * (dz / box.z).rounded(.toNearestOrAwayFromZero)
        }

        let distSq = dx * dx + dy * dy + dz * dz

        // Exchange contribution
        if exchangeConfig.computed && distSq <= exchangeCutoffSq {
          let isJTypeI = atomJ.type == typeI_E
          let isJTypeJ = atomJ.type == typeJ_E
          if (isITypeI_E && isJTypeJ) || (isITypeJ_E && isJTypeI) {
            let spinJ = atomJ.moments.spin
            omega.x += coeff_E * spinJ.x
            omega.y += coeff_E * spinJ.y
            omega.z += coeff_E * spinJ.z
          }
        }

        // DMI contribution
        if dmiConfig.computed && distSq <= dmiCutoffSq {
          let isJTypeI = atomJ.type == typeI_D
          let isJTypeJ = atomJ.type == typeJ_D
          if (isITypeI_D && isJTypeJ) || (isITypeJ_D && isJTypeI) {
            let dist = distSq.squareRoot()
            let spinJ = atomJ.moments.spin
            let sign: Double = (isITypeI_D && isJTypeJ) ? 1.0 : -1.0
            let dix = sign * val_D * dx / dist
            let diy = sign * val_D * dy / dist
            let diz = sign * val_D * dz / dist

            omega.x += coeff_D * (diy * spinJ.z - diz * spinJ.y)
            omega.y += coeff_D * (diz * spinJ.x - dix * spinJ.z)
            omega.z += coeff_D * (dix * spinJ.y - diy * spinJ.x)
          }
        }
      }
    }

    if uniaxialConfig.computed {
      let coeff = (gamma * uniaxialConfig.value) / muB
      let axis = uniaxialConfig.axis
      let dot = spin.x * axis.x + spin.y * axis.y + spin.z * axis.z
      let factor = (coeff / atom.g) * dot
      omega.x += factor * axis.x
      omega.y += factor * axis.y
      omega.z += factor * axis.z
    }

    if demagConfig.computed {
      let n = demagConfig.n
      omega.x -= n.x * spin.x
      omega.y -= n.y * spin.y
      omega.z -= n.z * spin.z
    }

    if stochasticConfig.computed {
      let stThermostat = stochasticConfig.thermostat
      let c =
        (2.0 * π * stThermostat.α * stThermostat.computeThermalCoefficient()
        / (ℏ.value * stochasticConfig.Δt))
        .squareRoot()
      omega.x += c * Double.random(in: -1...1)
      omega.y += c * Double.random(in: -1...1)
      omega.z += c * Double.random(in: -1...1)
    }

    if dampingConfig.computed {
      let alpha = dampingConfig.α
      let coeff = 1.0 / (1.0 + alpha * alpha)

      let tx = spin.y * omega.z - spin.z * omega.y
      let ty = spin.z * omega.x - spin.x * omega.z
      let tz = spin.x * omega.y - spin.y * omega.x

      omega.x = (omega.x + alpha * tx) * coeff
      omega.y = (omega.y + alpha * ty) * coeff
      omega.z = (omega.z + alpha * tz) * coeff
    }
    atom.ω = omega
  }

  /// Serializes the Interaction instance to a JSON string.
  ///
  /// This method encodes the entire Interaction object, including all atoms and
  /// interaction configurations, into a JSON-formatted string using Swift's Codable protocol.
  /// All field parameters and the current state of computed interactions are preserved.
  ///
  /// - Returns: A JSON string representation of the Interaction instance.
  ///
  /// - Throws: An error if the encoding fails or the data cannot be converted to a UTF-8 string.
  ///
  /// Example:
  /// ```swift
  /// let interaction = Interaction(atoms)
  ///     .zeemanField(Vector3(direction: "+z"), value: 1.5)
  ///     .dampingField(0.1)
  ///
  /// do {
  ///     let jsonString = try interaction.jsonify()
  ///     print(jsonString)  // Outputs JSON representation
  /// } catch {
  ///     print("Serialization failed: \(error)")
  /// }
  /// ```
  internal func jsonify() throws -> String {
    let data: Data = try JSONEncoder().encode(self)
    if let jsonString: String = String(data: data, encoding: .utf8) {
      return jsonString
    } else {
      throw SpinswiftError.encodingError("Failed to convert data to string")
    }
  }
}
