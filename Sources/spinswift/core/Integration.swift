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

    var h:Interaction

    init(_ h: Interaction = Interaction()) {
        self.h = h
    }

    func Evolve (stop: Double, Δt: Double, method: String? = nil, file: String) {
        switch method?.lowercased(){
        case "euler"? :
        self.EvolveEuler(stop: stop, Δt: Δt, fileName: file)
        case "expls"? :
        self.EvolveExpLs(stop: stop, Δt: Δt, fileName: file)
        case "symplectic"? :
        self.EvolveSymplectic(stop: stop, Δt: Δt, fileName: file)
        default: break
        }
    }

    func EvolveEuler(stop: Double, Δt: Double, fileName: String) {
        var time: Double = 0.0
        var content=String()

        while (time < stop) {
            content += String(time)
            for a in h.atoms {
                content += " "+String(a.spin.x)+" "+String(a.spin.y)+" "+String(a.spin.z)
                a.AdvanceSpin(method: "euler", Δt: Δt)
            }
            content += "\n"
            self.h.Update()
            time+=Δt
        }
        //let home = FileManager.default.homeDirectoryForCurrentUser
        SaveOnFile(data:content, fileName: fileName)
    }

    func EvolveExpLs(stop: Double, Δt: Double, fileName: String) {
    }

    func EvolveSymplectic(stop: Double, Δt: Double, fileName: String) {
    }

    func expLs(method: String, Δt: Double) {
        let NumberOfAtoms: Int = h.atoms.count
        for i:Int in 0...(NumberOfAtoms-2) {
            h.atoms[i].AdvanceSpin(method: method, Δt: Δt/2)
        }
        h.atoms[NumberOfAtoms-1].AdvanceSpin(method: method, Δt: Δt)
        for i: Int in 0...(NumberOfAtoms-2) {
            h.atoms[NumberOfAtoms-i-2].AdvanceSpin(method: method, Δt: Δt/2)
        }
    }

    func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 

}