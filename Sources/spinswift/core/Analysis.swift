/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

class Analysis {

    var atoms : [Atom] 

    init(_ atoms: [Atom]? = [Atom]()) {
        self.atoms = atoms!
    }

    func GetEnergy() -> Double {
        var e : Double = 0
        atoms.forEach {
            e += ($0.ω°$0.moments.spin)
        }
        return e
    }

    func GetMagnetization() -> Vector3 {
        var m : Vector3 = Vector3()
        var g : Double = 0
        atoms.forEach {
            m += (($0.g)*($0.moments.spin))
            g += ($0.g)
        }
        //print(String($0.spin.x))

        guard g != 0 else {return Vector3(0,0,0)}
        return (1.0/g)*m
    }

    func GetMagnetizationLength() -> Double {
        var mnorm: Double = 0
        var g : Double = 0
        atoms.forEach {
            mnorm += (($0.g)*($0.moments.spin).Norm())
            g += ($0.g)
        }
        guard g != 0 else {return 0}
        return (1.0/g)*mnorm
    }

    func GetTorque() -> Vector3 {
        var t: Vector3 = Vector3()
        atoms.forEach {
            t += ($0.ω)×($0.moments.spin)
        }
        return t
    }

    func getSuceptibility() -> Matrix3 {
        var χ: Matrix3 = Matrix3()
        var N: Double = 0
        atoms.forEach {
            let A = ($0.moments.spin ⊗ $0.moments.spin)
            //let B = $0.moments.sigma
            χ += $0.moments.sigma - A  
            N += 1


        }
        χ=(1/N)*χ
        return χ
    }

       func getCumulant() -> Matrix3 {
        var Σ: Matrix3 = Matrix3()
        var N: Double = 0
        atoms.forEach {
            Σ += $0.moments.sigma  
            N += 1


        }
        Σ=(1/N)*Σ
        return Σ
    }

    func GetTemperature(coefficient:Double? = 2.0) -> Double {
        let e: Double = self.GetEnergy()
        let t: Vector3 = self.GetTorque()
        let t2: Double = t°t
        let T: Double = (t2*(ℏ.value))/(e*coefficient!*(k_B.value))
        return T
    }
}
