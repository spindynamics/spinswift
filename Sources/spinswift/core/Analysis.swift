import Foundation

class Analysis {

    var atoms : [Atom] 

    init(_ atoms: [Atom]? = [Atom]()) {
        self.atoms = atoms!
    }

    func GetEnergy() -> Double {
        var e : Double = 0
        atoms.forEach {
            e += ($0.ω°$0.spin)
        }
        return e
    }

    func GetMagnetization() -> Vector3 {
        var m : Vector3 = Vector3()
        var g : Double = 0
        atoms.forEach {
            m += (($0.g)*($0.spin))
            g += ($0.g)
        }

        guard g != 0 else {return Vector3(0,0,0)}
        return (1.0/g)*m
    }

    func GetTemperature() -> Double {
        let T: Double = 0
        return T
    }
}