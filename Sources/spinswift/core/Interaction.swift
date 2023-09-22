import Foundation

/// A class for managing interactions between atoms
/// 
/// Interactions act between atoms. 
/// - Author: Pascal Thibaudeau
/// - Date: 14/04/2023
/// - Version: 0.1
class Interaction : Codable {
    // Local interactions
    var atom : Atom

    init(_ atom: Atom? = Atom()) {
        self.atom = atom!
        self.atom.ω = Vector3(0,0,0)
        }

    func Dampening(_ value: Double) -> Interaction {
        let coeff: Double = 1.0/(1.0+value*value)
        atom.ω += (value*(atom.spin × atom.ω))
        atom.ω = coeff*(atom.ω)
        return self
    }

    func Demagnetizing(_ nx: Double, _ ny: Double , _ nz: Double) -> Interaction {
        atom.ω -= Vector3(nx*(atom.spin.x), ny*(atom.spin.y), nz*(atom.spin.z))
        return self
    }

    func Uniaxial(_ axis: Vector3, value:Double) -> Interaction {
        atom.ω += (value*(atom.spin°axis)*axis)
        return self
    }
    
    func Zeeman(_ axis: Vector3, value: Double) -> Interaction {
        atom.ω += (value*axis)
        return self
    }

    func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}