/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A class for managing interactions between atoms
/// 
/// Interactions act between atoms. 
/// - Author: Pascal Thibaudeau
/// - Date: 14/04/2023
/// - Version: 0.1
class Interaction : Codable {
    
    var atoms :[Atom]

    init(_ atoms: [Atom]? = [Atom]()) {
        self.atoms = atoms!
        atoms!.forEach {
            $0.ω = Vector3(0,0,0)
        }
    }

    func Dampening(_ value: Double) -> Interaction {
        let coeff: Double = 1.0/(1.0+value*value)
        atoms.forEach {
            $0.ω += (value*($0.spin × $0.ω))
            $0.ω = coeff * ($0.ω)
        }
        return self
    }

    func Demagnetizing(_ nx: Double, _ ny: Double , _ nz: Double) -> Interaction {
        assert(nx+ny+nz == 1,"Demagnetizing: the sum of the coefficients should be 1")
        atoms.forEach {
            $0.ω -= Vector3(nx*($0.spin.x), ny*($0.spin.y), nz*($0.spin.z))
        }
        return self
    }

    func Exchange(typeI: Int, typeJ: Int, value: Double, Rcut: Double? = Double()) -> Interaction {
        let NumberOfAtoms: Int = atoms.count
        for i: Int in 0...NumberOfAtoms-1 where atoms[i].type == typeI {
           for j: Int in 0...i where atoms[j].type == typeJ && Distance(atoms[i].position, atoms[j].position)<=Rcut! && Distance(atoms[i].position, atoms[j].position)>0 {
            atoms[i].ω += value*atoms[j].spin
            atoms[j].ω = atoms[i].ω
           }
        }
        return self
    }

    func Uniaxial(_ axis: Vector3, value:Double) -> Interaction {
        atoms.forEach {
            $0.ω += (value*($0.spin°axis)*axis)
        }
        return self
    }
    
    func Zeeman(_ axis: Vector3, value: Double) -> Interaction {
        atoms.forEach {
            $0.ω += (value*axis)
        }
        return self
    }

    func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}