/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A class for integrating the dynamics of spins
///
/// The purpose of this class is to integrate a collection of particles.
/// - Author: Pascal Thibaudeau
/// - Date: 03/10/2023
/// - Version: 0.1

class Integrate: Codable {

    var h: Interaction

    init(_ h: Interaction = Interaction()) {
        self.h = h
    }

    func evolve(stop: Double, Δt: Double, method: String? = nil, file: String) {
        switch method?.lowercased() {
        case "euler"?:
            self.evolveEuler(stop: stop, Δt: Δt, fileName: file)
        case "expls"?:
            self.evolveExpLs(stop: stop, Δt: Δt, fileName: file)
        case "symplectic"?:
            self.evolveSymplectic(stop: stop, Δt: Δt, fileName: file)
        default: break
        }
    }

    func evolveEuler(stop: Double, Δt: Double, fileName: String) {
        var currentTime: Double = 0.0
        var content = String()

        while currentTime < stop {
            content += String(currentTime)
            for a in h.atoms {
                content += " " + String(a.spin.x) + " " + String(a.spin.y) + " " + String(a.spin.z)
                a.advanceSpin(method: "euler", Δt: Δt)
            }
            content += "\n"
            self.h.update()
            currentTime += Δt
        }
        //let home = FileManager.default.homeDirectoryForCurrentUser
        saveOnFile(data: content, fileName: fileName)
    }

    func evolveExpLs(stop: Double, Δt: Double, fileName: String) {
    }

    func evolveSymplectic(stop: Double, Δt: Double, fileName: String) {
    }

    func expLs(method: String, Δt: Double) {
        let NumberOfAtoms: Int = h.atoms.count
        for i: Int in 0...(NumberOfAtoms - 2) {
            h.atoms[i].advanceSpin(method: method, Δt: Δt / 2)
        }
        h.atoms[NumberOfAtoms - 1].advanceSpin(method: method, Δt: Δt)
        for i: Int in 0...(NumberOfAtoms - 2) {
            h.atoms[NumberOfAtoms - i - 2].advanceSpin(method: method, Δt: Δt / 2)
        }
    }

    func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        if let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        } else {
            throw NSError(
                domain: "jsonifyError", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"])
        }
    }

}
