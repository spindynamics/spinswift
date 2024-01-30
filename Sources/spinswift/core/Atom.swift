/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A class for managing atomic properties
/// 
/// An atomic system is a collection of atoms and relationships with them. 
/// - Author: Pascal Thibaudeau
/// - Date: 14/04/2023
/// - Version: 0.1
class Atom : Codable {
    /// Name of the atomic species
    var name : String
    /// Identifier of the atomic type
    var type : Int
    /// Atomic Landé factor in Bohr's magneton unit   
    var g : Double  
    /// Atomic Cartesian position 
    var position : Vector3 
    /// Atomic Cartesian spin direction
    var spin : Vector3 
    /// Atomic pulsation vector around its spin spins
    var ω: Vector3 

    /**
        Initializes a new atom with the provided parts and specifications.

        - Parameters:
            - name: The name of the atom
            - type: The type of the atom
            - position: The Cartesian position of the atom
            - spin: The spin direction of the atom as a unit vector
            - ω: The pulsation vector located on the atom
            - g: The Landé factor of the atom in Bohr's magneton unit
        
        - Returns: A new atom
    */
    init(name: String? = String(), type: Int? = Int(), position: Vector3? = Vector3(), spin: Vector3? = Vector3(), ω: Vector3? = Vector3(), g: Double? = Double()){
    //    if name.isEmpty {fatalError("A name has to be provided")}
        self.name = name!
        self.type = type!
        self.position = position!
        self.spin = spin!
        self.ω = ω!
        guard g! >= 0 else {fatalError("g factor must be positive!")}
        self.g = g!
    }

    /**
        Compute the atomic spin direction according to a precession motion around its local pulsation vector.

        - Parameters: 
          - method: The type of method used either [euler](euler) or [symplectic](symplectic)
          - Δt: The timestep used (internal unit in ps).

        - Returns: The Cartesian vector pointing the new direction and located on the unit sphere
    */
   func AdvanceSpin(method: String, Δt: Double) {
        var s: Vector3 = Vector3()
        switch method.lowercased() {
        case "euler" :
            s = spin + Δt * (ω × spin)
        case "symplectic" :
            let ω2: Double = ω°ω
            let c: Double = 0.25*Δt*Δt
            let c2: Double = 1.0/(1.0 + c*ω2)
            var s1: Vector3 = c*((2.0*(ω°spin))*ω - ω2*spin)
            s1 += Δt * (ω × spin)
            s = c2 * (spin + s1)
        case "full" :
            let n: Double = ω.Norm()
            let Ω: Vector3 = (1.0/n)*ω
            let ξ: Double = n*Δt
            let χ: Double = Ω°spin
            s = cos(ξ)*spin + sin(ξ)*(Ω × spin) + (χ*(1.0-cos(ξ)))*Ω
        default: break
        }
        spin = s
        spin.Normalize()
    }
    
    func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}
