/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

class Analysis {

    var atoms: [Atom]

    init(_ atoms: [Atom]? = nil) {
        self.atoms = atoms ?? []
    }

    func getEnergy() -> Double {
        return atoms.reduce(0) { $0 + ($1.ω ° $1.moments.spin) }
    }

    func getMagnetization() -> Vector3 {
        let (m, g) = atoms.reduce((Vector3.zero, 0)) { (acc, atom) in
            return (acc.0 + (atom.g * atom.moments.spin), acc.1 + atom.g)
        }
        guard g != 0 else { return .zero }
        return (1.0 / g) * m
    }
  
    func getMagnetizationLength() -> Double {
        var mnorm: Double = 0
        var g : Double = 0
        atoms.forEach {
            mnorm += (($0.g)*($0.moments.spin).Norm())
            g += ($0.g)
        }
        guard g != 0 else {return 0}
        return (1.0/g)*mnorm
    }

    func getTorque() -> Vector3 {
        return atoms.reduce(Vector3.zero) { $0 + ($1.ω × ($1.moments.spin)) }
    }

    func getTemperature(coefficient: Double? = nil) -> Double {
        let e = self.getEnergy()
        let t = self.getTorque()
        let t2 = t ° t
        let T = (t2 * ℏ.value) / (e * (coefficient ?? 2.0) * k_B.value)
        return T
    }

    func getInstantEnergy() -> Double {
        var e : Double = 0
        atoms.forEach {
            e += ($0.ω°$0.moments.spin)
        }
        return e
    }

    func getSuceptibility() -> Matrix3 {
        var χ: Matrix3 = Matrix3()
        var N: Double = 0
        atoms.forEach {
            let A = ($0.moments.spin ⊗ $0.moments.spin)
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
}
