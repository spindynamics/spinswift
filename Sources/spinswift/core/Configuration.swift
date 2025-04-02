/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

typealias Magnetization = Atom

typealias Stack = [Atom]

//Strucutre to define initial parameters for an atom
struct InitialParam: Codable {
    var name: String
    var type: Int
    var spin: Vector3
    var moments: Atom.Moments
    var position: Vector3
    var g: Double
    var ℇ: Double
    var Vat: Double
    var Dref: Double
    var vanHove: Double

    init(name: String, type: Int, spin: Vector3? = Vector3(), moments: Atom.Moments?, position: Vector3? = Vector3(), g: Double? = Double(), ℇ: Double? = Double(), Vat: Double? = Double(), Dref: Double? = Double(), vanHove: Double? = Double()) {
            self.name = name
            self.type = type
            self.spin = spin!
            self.moments = moments!
            self.position = position!
            self.g = g!
            self.ℇ = ℇ!
            self.Vat = Vat!
            self.Dref = Dref!
            self.vanHove = vanHove!
        }
}

//Strucutre to define boudary conditions
struct BoundaryConditions: Codable {
    var BoxSize: Vector3
    var PBC: String

    init(BoxSize: Vector3? = Vector3(), PBC: String? = String()) {
        self.BoxSize = BoxSize!
        self.PBC = PBC!
    }
}

//Generate the crystalstrucutres (modifie l'initialisation)
func GenerateCrystalStructure(UCAtoms: [Atom], supercell: (x: Int, y: Int, z: Int), LatticeConstant: Double, InitParam: InitialParam) -> [Atom] { 
    var crystalStructure: [Atom] = []
    let a=LatticeConstant 
    for i in 0..<supercell.x { 
        for j in 0..<supercell.y { 
            for k in 0..<supercell.z { 
                let translationVector = Vector3(Double(i), Double(j), Double(k)) 
                for atom in UCAtoms { 
                    let newPosition = a*(atom.position + translationVector) 
                    let newAtom = Atom(position: newPosition)
                    //let sp: Vector3 = Vector3(direction: "random")
                    //let sg: Matrix3 = sp ⊗ sp
                    //let mm = Atom.Moments(spin: sp, sigma: sg)
            
                    newAtom.name = InitParam.name; newAtom.type=InitParam.type; 
                    newAtom.moments=InitParam.moments; newAtom.g=InitParam.g; newAtom.ℇ=InitParam.ℇ
                    newAtom.Vat=InitParam.Vat; newAtom.Dref=InitParam.Dref; newAtom.vanHove=InitParam.vanHove
            
                    crystalStructure.append(newAtom)
                    } 
    } } } 
    return crystalStructure 
}


func substituteRandomAtoms(structure: [Atom], InitParam: InitialParam, Percentage: Double) -> [Atom] {
    var Alloy: [Atom] = structure
    let N: Double = Percentage/100 // round it is better
    let Atomstosubstitute: Double = N*Double(Alloy.count)
    var atomeindex: Int = 0 
    let RandomAtoms = Array(0...Alloy.count-1).shuffled()

    for i in 0..<Int(Atomstosubstitute) {
        atomeindex = RandomAtoms[i]
        //print(String(atomeindex))
        Alloy[atomeindex].name = InitParam.name; Alloy[atomeindex].type=InitParam.type; 
        Alloy[atomeindex].moments=InitParam.moments; Alloy[atomeindex].g=InitParam.g; Alloy[atomeindex].ℇ=InitParam.ℇ
        Alloy[atomeindex].Vat=InitParam.Vat; Alloy[atomeindex].Dref=InitParam.Dref; Alloy[atomeindex].vanHove=InitParam.vanHove
    }

    return Alloy

}

/*
func substituteRandomAtoms(structure: [Atom], InitParam: InitialParam, Percentage: Double) -> [Atom] {
    // Create a deep copy of the original structure
    var Alloy = structure
    
    // Calculate number of atoms to substitute
    let Atomstosubstitute = Int(round((Percentage / 100) * Double(Alloy.count)))

    // Randomly shuffle indices and take the required number
    let RandomAtoms = (0..<Alloy.count-1).shuffled().prefix(Atomstosubstitute)

    // Perform substitution
    for atomeindex in RandomAtoms {
        let atom = Alloy[atomeindex] // Get reference to the copied atom
        atom.name = InitParam.name
        atom.type = InitParam.type
        atom.moments = InitParam.moments
        atom.g = InitParam.g
        atom.ℇ = InitParam.ℇ
        atom.Vat = InitParam.Vat
        atom.Dref = InitParam.Dref
        atom.vanHove = InitParam.vanHove
    }

    return Alloy
}
*/

func substituteSpecificAtoms(structure: [Atom], InitParam: InitialParam, unitCellAtoms: [Atom], supercellSize: (Int, Int, Int)) -> [Atom] {
    // Create a deep copy of the original structure
    var Alloy = structure

    // Identify the reference atom in the unit cell (e.g., the one at (0,0,0))
    guard let referenceAtom = unitCellAtoms.first else {
        print("Error: Unit cell is empty.")
        return Alloy
    }

    // Function to check if an atom is a translation of the reference atom
    func isTranslation(of reference: Atom, atom: Atom, supercellSize: (Int, Int, Int)) -> Bool {
        let (sx, sy, sz) = supercellSize
        return (atom.position.x - reference.position.x).truncatingRemainder(dividingBy: Double(sx)) == 0 &&
               (atom.position.y - reference.position.y).truncatingRemainder(dividingBy: Double(sy)) == 0 &&
               (atom.position.z - reference.position.z).truncatingRemainder(dividingBy: Double(sz)) == 0
    }

    // Perform substitution only on atoms that match the reference pattern
    for atom in Alloy {
        if isTranslation(of: referenceAtom, atom: atom, supercellSize: supercellSize) {
            atom.name = InitParam.name
            atom.type = InitParam.type
            atom.moments = InitParam.moments
            atom.g = InitParam.g
            atom.ℇ = InitParam.ℇ
            atom.Vat = InitParam.Vat
            atom.Dref = InitParam.Dref
            atom.vanHove = InitParam.vanHove
        }
    }

    return Alloy
}

//Calculate the inter-atomic distances with or without periodic boundary conditions
func ComputeDistance(BCs: BoundaryConditions, atom1: Atom, atom2: Atom) -> Double {
    var A: Double = 0.0
    let BoxSize: Vector3 = BCs.BoxSize; let PBC: String = BCs.PBC
    switch PBC.lowercased() {
        case "off" :
            A=Distance(atom1.position, atom2.position)  
        case "on" :
            let xij = atom1.position - atom2.position
            xij.x -= BoxSize.x * (xij.x/BoxSize.x).rounded(.toNearestOrAwayFromZero)
            xij.y -= BoxSize.y * (xij.y/BoxSize.y).rounded(.toNearestOrAwayFromZero)
            xij.z -= BoxSize.z * (xij.z/BoxSize.z).rounded(.toNearestOrAwayFromZero)
            A=((xij)°(xij)).squareRoot()
        default: break
    }
    return A
}