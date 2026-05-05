/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation
import Logging
import PythonKit

typealias Magnetization = Atom

typealias Stack = [Atom]

/// A structure representing initial physical parameters for an atom.
public struct InitialParameters: Codable {
  /// The name of the atomic species.
  var name: String
  /// The type identifier for the atom.
  var type: Int
  /// The initial spin direction as a unit vector.
  var spin: Vector3
  /// The initial spin moments (first and second order).
  var moments: Atom.Moments
  /// The initial position in space.
  var position: Vector3
  /// The Landé factor.
  var g: Double

  /// Initializes a new set of initial parameters.
  /// - Parameters:
  ///   - name: The name of the atom.
  ///   - type: The type identifier.
  ///   - spin: The initial spin vector.
  ///   - moments: The initial spin moments.
  ///   - position: The initial position.
  ///   - g: The Landé factor.
  public init(
    name: String, type: Int, spin: Vector3? = Vector3(), moments: Atom.Moments?,
    position: Vector3? = Vector3(), g: Double? = Double()
  ) {
    self.name = name
    self.type = type
    self.spin = spin!
    self.moments = moments!
    self.position = position!
    self.g = g!
  }
}

/// A structure representing boundary conditions for a simulation box.
public struct BoundaryConditions: Codable {
  /// The dimensions of the simulation box.
  var BoxSize: Vector3
  /// Periodic Boundary Conditions ("on" or "off").
  var PBC: String

  /// Initializes a new set of boundary conditions.
  /// - Parameters:
  ///   - BoxSize: The size of the box.
  ///   - PBC: The PBC status ("on" or "off").
  public init(BoxSize: Vector3? = Vector3(), PBC: String? = String()) {
    self.BoxSize = BoxSize!
    self.PBC = PBC!
  }
}

/// A class for reading Crystallographic Information Files (CIF) and extracting structural data.
///
/// This class uses `pymatgen` via PythonKit to parse CIF files and convert them into
/// internal lattice and atom representations.
public class CIFReader {

  /// Errors that can occur during CIF reading.
  public enum Error: Swift.Error, CustomStringConvertible {
    /// Thrown when the `.python-version` file cannot be found.
    case pythonVersionFileNotFound
    /// Thrown when the CIF file does not exist at the specified path.
    case cifFileNotFound(String)

    /// A human-readable description of the error.
    public var description: String {
      switch self {
      case .pythonVersionFileNotFound:
        return "Could not find .python-version file"
      case .cifFileNotFound(let path):
        return "CIF file not found at: \(path)"
      }
    }
  }

  /// A structure representing crystal lattice parameters.
  public struct Lattice: Codable {
    /// Lattice parameter a.
    public var a: Double
    /// Lattice parameter b.
    public var b: Double
    /// Lattice parameter c.
    public var c: Double
    /// Angle alpha in degrees.
    public var alpha: Double
    /// Angle beta in degrees.
    public var beta: Double
    /// Angle gamma in degrees.
    public var gamma: Double
    /// Volume of the unit cell.
    public var volume: Double
  }

  /// A structure holding all crystallographic data extracted from a CIF file.
  public struct CrystallographicData: Codable {
    /// The crystal lattice.
    public var lattice: Lattice
    /// The collection of atoms in the unit cell.
    public var atoms: [Atom]
    /// The space group symbol.
    public var spaceGroup: String
    /// The chemical formula.
    public var formula: String
  }

  private let logger: Logger = Logger(label: "CIFReader")

  /// Initializes a new CIF reader.
  public init() {}

  /// Reads a CIF file and returns the crystallographic data.
  /// - Parameter filePath: The absolute path to the CIF file.
  /// - Returns: A `CrystallographicData` object containing the extracted information.
  /// - Throws: `CIFReader.Error` if the file is missing or `PythonKit` configuration fails.
  public func read(filePath: String) throws -> CrystallographicData {
    // Configure the uv-managed Python environment and .venv site-packages.
    PythonEnvironment.configure()

    let fileManager: FileManager = FileManager.default
    let core: PythonObject = Python.import("pymatgen.core")

    if !fileManager.fileExists(atPath: filePath) {
      throw Error.cifFileNotFound(filePath)
    }

    let structure: PythonObject = core.Structure.from_file(filePath)

    // Extract Lattice
    let latticeObj: PythonObject = structure.lattice
    let lat: CIFReader.Lattice = Lattice(
      a: Double(latticeObj.a)!,
      b: Double(latticeObj.b)!,
      c: Double(latticeObj.c)!,
      alpha: Double(latticeObj.alpha)!,
      beta: Double(latticeObj.beta)!,
      gamma: Double(latticeObj.gamma)!,
      volume: Double(latticeObj.volume)!
    )

    // Extract Space Group
    let spaceGroupInfo: PythonObject = structure.get_space_group_info()
    let spaceGroupSymbol: String = String(spaceGroupInfo[0])!

    // Extract Formula
    let formula: String = String(structure.formula)!

    // Extract Atoms
    var atoms: [Atom] = []
    for site: PythonObject in structure {
      let position: Vector3 = Vector3(
        x: Double(site.frac_coords[0])!,
        y: Double(site.frac_coords[1])!,
        z: Double(site.frac_coords[2])!
      )
      let atom: Atom = Atom(
        name: String(site.specie.symbol)!,
        type: 1,
        position: position,
        moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
        g: 2.0
      )
      atoms.append(atom)
    }

    return CrystallographicData(
      lattice: lat,
      atoms: atoms,
      spaceGroup: spaceGroupSymbol,
      formula: formula
    )
  }
}

/// Generates a crystal structure by replicating a unit cell into a supercell.
/// - Parameters:
///   - UCAtoms: The atoms in the unit cell.
///   - supercell: A tuple specifying the number of unit cells in each direction (x, y, z).
///   - LatticeConstant: The lattice constant for scaling.
///   - initialParameters: The initial physical parameters for the new atoms.
/// - Returns: An array of atoms forming the crystal structure.
public func GenerateCrystalStructure(
  UCAtoms: [Atom], supercell: (x: Int, y: Int, z: Int), LatticeConstant: Double,
  initialParameters: InitialParameters
) -> [Atom] {
  var crystalStructure: [Atom] = []
  let a: Double = LatticeConstant
  for i: Int in 0..<supercell.x {
    for j: Int in 0..<supercell.y {
      for k: Int in 0..<supercell.z {
        let translationVector: Vector3 = Vector3(Double(i), Double(j), Double(k))
        for atom: Atom in UCAtoms {
          let newPosition: Vector3 = a * (atom.position + translationVector)
          let newAtom: Atom = Atom(position: newPosition)

          newAtom.name = initialParameters.name
          newAtom.type = initialParameters.type
          newAtom.moments = initialParameters.moments
          newAtom.g = initialParameters.g

          crystalStructure.append(newAtom)
        }
      }
    }
  }
  return crystalStructure
}

/// Substitutes a random percentage of atoms in a structure with new parameters.
/// - Parameters:
///   - structure: The base crystal structure.
///   - initialParameters: The parameters to apply to the substituted atoms.
///   - Percentage: The percentage of atoms to substitute (0-100).
/// - Returns: The modified crystal structure.
public func substituteRandomAtoms(
  structure: [Atom], initialParameters: InitialParameters, Percentage: Double
) -> [Atom] {
  let Alloy: [Atom] = structure
  let N: Double = Percentage / 100  // round it is better
  let Atomstosubstitute: Double = N * Double(Alloy.count)
  let RandomAtoms = Array(0...Alloy.count - 1).shuffled()

  for i: Int in 0..<Int(Atomstosubstitute) {
    let atomindex: Int = RandomAtoms[i]
    //print(String(atomeindex))
    Alloy[atomindex].name = initialParameters.name
    Alloy[atomindex].type = initialParameters.type
    Alloy[atomindex].moments = initialParameters.moments
    Alloy[atomindex].g = initialParameters.g
  }

  return Alloy
}

/// Substitutes specific atoms in a structure that match a periodic translation pattern.
/// - Parameters:
///   - structure: The base crystal structure.
///   - initialParameters: The parameters to apply to the substituted atoms.
///   - unitCellAtoms: The reference unit cell atoms.
///   - supercellSize: The size of the supercell.
/// - Returns: The modified crystal structure.
public func substituteSpecificAtoms(
  structure: [Atom], initialParameters: InitialParameters, unitCellAtoms: [Atom],
  supercellSize: (Int, Int, Int)
) -> [Atom] {
  // Create a deep copy of the original structure
  let Alloy: [Atom] = structure

  // Identify the reference atom in the unit cell (e.g., the one at (0,0,0))
  guard let referenceAtom: Atom = unitCellAtoms.first else {
    print("Error: Unit cell is empty.")
    return Alloy
  }

  // Function to check if an atom is a translation of the reference atom
  func isTranslation(of reference: Atom, atom: Atom, supercellSize: (Int, Int, Int)) -> Bool {
    let (sx, sy, sz) = supercellSize
    return (atom.position.x - reference.position.x).truncatingRemainder(dividingBy: Double(sx))
      == 0
      && (atom.position.y - reference.position.y).truncatingRemainder(dividingBy: Double(sy))
        == 0
      && (atom.position.z - reference.position.z).truncatingRemainder(dividingBy: Double(sz))
        == 0
  }

  // Perform substitution only on atoms that match the reference pattern
  for atom: Atom in Alloy {
    if isTranslation(of: referenceAtom, atom: atom, supercellSize: supercellSize) {
      atom.name = initialParameters.name
      atom.type = initialParameters.type
      atom.moments = initialParameters.moments
      atom.g = initialParameters.g
    }
  }

  return Alloy
}

/// Calculates the distance between two atoms, optionally considering periodic boundary conditions.
/// - Parameters:
///   - BCs: The boundary conditions for the simulation.
///   - atom1: The first atom.
///   - atom2: The second atom.
/// - Returns: The computed distance.
public func ComputeDistance(BCs: BoundaryConditions, atom1: Atom, atom2: Atom) -> Double {
  var A: Double = 0.0
  let BoxSize: Vector3 = BCs.BoxSize
  let PBC: String = BCs.PBC
  switch PBC.lowercased() {
  case "off":
    A = Distance(atom1.position, atom2.position)
  case "on":
    var xij: Vector3 = atom1.position - atom2.position
    xij.x -= BoxSize.x * (xij.x / BoxSize.x).rounded(.toNearestOrAwayFromZero)
    xij.y -= BoxSize.y * (xij.y / BoxSize.y).rounded(.toNearestOrAwayFromZero)
    xij.z -= BoxSize.z * (xij.z / BoxSize.z).rounded(.toNearestOrAwayFromZero)
    A = xij.norm()
  default: break
  }
  return A
}
