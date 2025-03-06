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
class Interaction : Codable {
    
    public var atoms: [Atom]

    private struct Zeeman : Codable {
        var computed: Bool = false
        var axis: Vector3 = Vector3()
        var value: Double = Double()
    }

    private struct STT_Damping : Codable {
        /// true or false if the damping is computed
        var computed: Bool = false
        var Pol: Vector3 = Vector3()
        var Amplitde: Double = Double()
    }

    private struct Exchange : Codable {
        /// true or false if the exchange is computed
        var computed: Bool = false
        //var J: Double = Double()
        //var n: [Int] = [Int]()
        var typeI: Int = Int()
        var typeJ: Int = Int()
        var value: Double = Double()
        var Rcut: Double = Double()
        var BCs: BoundaryConditions = BoundaryConditions()
    }
    private struct DMI : Codable {
        /// true or false if the DMI is computed
        var computed: Bool = false
        var D: Double = Double()
        var n: [Int] = [Int]()
    }
    private struct Damping : Codable {
        /// true or false if the damping is computed
        var computed: Bool = false
        var α: Double = Double()
    }
    private struct Uniaxial : Codable {
        /// true or false if the uniaxial anisotropy field is computed
        var computed: Bool = false
        var axis: Vector3 = Vector3()
        var value: Double = Double()
    }
    private struct Demagnetizing : Codable {
        /// true or false if the uniform demagnetizing field is computed
        var computed: Bool = false
        /// 3 values such as n[1]+n[2]+n[3]=1
        var n:[Double] = [Double]()
    }

    private var isZeeman : Zeeman = Zeeman()
    private var isSTT_Damping : STT_Damping = STT_Damping()
    private var isExchange : Exchange = Exchange()
    private var isDMI : DMI = DMI()
    private var isDamping : Damping = Damping()
    private var isUniaxial : Uniaxial = Uniaxial()
    private var isDemagnetizing : Demagnetizing = Demagnetizing()

    init(_ atoms: [Atom] = [Atom]()) {
        self.atoms = atoms
        atoms.forEach {
            $0.ω = Vector3(0,0,0)
        }
    }

    func Dampening(_ value: Double) -> Interaction {
        let coeff: Double = 1.0/(1.0+value*value)
        atoms.forEach {
            $0.ω += (value*($0.moments.spin × $0.ω))
            $0.ω = coeff * ($0.ω)
        }
        self.isDamping = Interaction.Damping(computed:true,α:value)
        return self
    }


    func DemagnetizingField(_ nx: Double, _ ny: Double , _ nz: Double) -> Interaction {
        assert(nx+ny+nz == 1,"Demagnetizing: the sum of the coefficients should be 1")
        atoms.forEach {
            $0.ω -= Vector3(nx*($0.moments.spin.x), ny*($0.moments.spin.y), nz*($0.moments.spin.z))
        }
        self.isDemagnetizing = Interaction.Demagnetizing(computed: true, n: [nx,ny,nz])
        return self
    }

    func ExchangeField(typeI: Int, typeJ: Int, value: Double, Rcut: Double, BCs: BoundaryConditions) -> Interaction {
        let NumberOfAtoms: Int = atoms.count
        //var nn: Int = 0
        for i: Int in 0...NumberOfAtoms-1 where atoms[i].type == typeI {
           for j: Int in 0...i where atoms[j].type == typeJ && ComputeDistance(BCs: BCs,atom1: atoms[i],atom2: atoms[j])<=Rcut && ComputeDistance(BCs: BCs,atom1: atoms[i],atom2: atoms[j]) != 0 {
            //if (i == 0 || j == 0) {nn+=1}      
            atoms[i].ω += value*atoms[j].moments.spin
            //(atoms[j].moments.spin - (atoms[j].moments.sigma - (atoms[j].moments.spin ⊗ atoms[j].moments.spin))*Vector3(1,1,1))   
            atoms[j].ω += value*atoms[i].moments.spin
            //(atoms[i].moments.spin - (atoms[i].moments.sigma - (atoms[i].moments.spin ⊗ atoms[i].moments.spin))*Vector3(1,1,1))
            //pow(atoms[j].moments.spin.Norm(),100000)
           }
           //print("i="+String(i)+"====================================")
           //atoms[2].ω.Print()
        }
        //print(String(nn))
        self.isExchange = Interaction.Exchange(computed: true, typeI: typeI, typeJ: typeJ, value: value, Rcut: Rcut, BCs: BCs)
        return self
    }

    func UniaxialField(_ axis: Vector3, value: Double) -> Interaction {
        let coeff = value/(ℏ.value)
        atoms.forEach {
            $0.ω += coeff*($0.moments.spin°axis)*axis
        }
        self.isUniaxial = Interaction.Uniaxial(computed: true, axis: axis, value: value)
        return self
    }
    
    func ZeemanField(_ axis: Vector3, value: Double) -> Interaction {
        let coeff = (γ.value)*value
        ///(ℏ.value)
        atoms.forEach {
            $0.ω += coeff*axis
        }
        self.isZeeman = Interaction.Zeeman(computed: true, axis: axis, value: value)
        return self
    }

    func STT_DampingLike(Pol: Vector3, Amplitde: Double) -> Interaction {
        atoms.forEach {
            $0.ω += (Amplitde*(Pol × $0.moments.spin))
        }
        self.isSTT_Damping = Interaction.STT_Damping(computed:true, Pol: Pol, Amplitde: Amplitde)
        return self
    }

    func Update() {
        //erase the effective fields first
        atoms.forEach {$0.ω = Vector3(0,0,0)}
        //If the fields have been computed, then update them with the proper set of values
        if (isZeeman.computed) {self.ZeemanField(isZeeman.axis,value:isZeeman.value)}
        if (isSTT_Damping.computed) {self.STT_DampingLike(Pol:isSTT_Damping.Pol,Amplitde:isSTT_Damping.Amplitde)}
        if (isExchange.computed) {self.ExchangeField(typeI: isExchange.typeI, typeJ: isExchange.typeJ, value: isExchange.value, Rcut: isExchange.Rcut, BCs: isExchange.BCs)}
        if (isUniaxial.computed) {self.UniaxialField(isUniaxial.axis,value:isUniaxial.value)}
        if (isDamping.computed) {self.Dampening(isDamping.α)}
    }

    func Update(i:Int) {  
    }

    func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}