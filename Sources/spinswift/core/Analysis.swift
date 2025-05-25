/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

class Analysis {

    var atoms: [Atom]

    init(_ atoms: [Atom]? = nil) {
        self.atoms = atoms ?? []
    }

    func getEnergy() -> Double {
        return atoms.reduce(0) { $0 + ($1.ω ° $1.spin) }
    }

    func getMagnetization() -> Vector3 {
        let (m, g) = atoms.reduce((Vector3.zero, 0)) { (acc, atom) in
            return (acc.0 + (atom.g * atom.spin), acc.1 + atom.g)
        }
        guard g != 0 else { return .zero }
        return (1.0 / g) * m
    }

    func getTorque() -> Vector3 {
        return atoms.reduce(Vector3.zero) { $0 + ($1.ω × ($1.spin)) }
    }

    func getTemperature(coefficient: Double? = nil) -> Double {
        let e = self.getEnergy()
        let t = self.getTorque()
        let t2 = t ° t
        let T = (t2 * ℏ.value) / (e * (coefficient ?? 2.0) * k_B.value)
        return T
    }
}
