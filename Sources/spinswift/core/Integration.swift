/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A class for integrating the dynamics of spins
///
/// The purpose of this class is to integrate a collection of particles.
/// - Author: Pascal Thibaudeau
/// - Date: 03/10/2023
/// - Update author: Mouad Fattouhi
/// - Updated: 11/09/2024
/// - Version: 0.1

class Integrate: Codable {

    var h: Interaction

    init(_ h: Interaction = Interaction()) {
        self.h = h
    }

    func evolve (stop: Double, Δt: Double, method: String? = nil, file: String) {
        switch method?.lowercased(){
        case "euler"? :
        self.evolveEuler(stop: stop, Δt: Δt, fileName: file)
        case "rk4"? :
        self.evolveRK45(stop: stop, Δt: Δt, fileName: file)
        default: break
        }
    }

    func evolveEuler(stop: Double, Δt: Double, fileName: String) {
        var currentTime: Double = 0.0
        var content=String()
         while (currentTime < stop) {
            content += String(currentTime)+" "
            for a in h.atoms {
                a.advanceMoments(method: "euler", Δt: Δt)
            }
            let m : Vector3 = Analysis(h.atoms).GetMagnetization()
            let mnorm : Double = Analysis(h.atoms).GetMagnetizationLength()
            content += " "+String(m.x)+" "+String(m.y)+" "+String(m.z)+" "+String(mnorm)+"\n"
            self.h.Update()
            currentTime+=Δt
          }

        
        //let home = FileManager.default.homeDirectoryForCurrentUser
        if (fileName != "NoFile") {SaveOnFile(data:content, fileName: fileName)}
    }


    func evolveRK45(stop: Double, Δt: Double, fileName: String, Temp: Double? = Double(), alpha: Double? = Double(), thermostat: String? = String()){
        var currentTime: Double = 0.0
        var content=String()
         while (currentTime < stop){
            content += String(currentTime)+" "
            let m : Vector3 = Analysis(h.atoms).GetMagnetization()
            let mnorm : Double = Analysis(h.atoms).GetMagnetizationLength()
            let a1: Atom = h.atoms[23]
            let a2: Atom = h.atoms[12]
            //content += " "+String(m.x)+" "+String(m.y)+" "+String(m.z)+" "+String(mnorm)+" "
            content += " "+String(a1.moments.spin.x)+" "+String(a1.moments.spin.y)+" "+String(a1.moments.spin.z)+" "+String(a1.moments.spin.Norm())+" "
            content += " "+String(a2.moments.spin.x)+" "+String(a2.moments.spin.y)+" "+String(a2.moments.spin.z)+" "+String(a2.moments.spin.Norm())+"\n"
            for a in h.atoms {
                //content += " "+String(a.spin.x)+" "+String(a.spin.y)+" "+String(a.spin.z)+"\n"
                //content += " "+String(a.Σ.xx)+" "+String(a.Σ.yy)+" "+String(a.Σ.zz)
                //content += " "+String(a.Σ.xy)+" "+String(a.Σ.yz)+" "+String(a.Σ.zy)
                a.advanceMoments(method: "rk4", Δt: Δt, T: Temp!, α: alpha!, thermostat: thermostat!)
            }
            self.h.Update()
            currentTime+=Δt
          }
        //let home = FileManager.default.homeDirectoryForCurrentUser
        if (fileName != "NoFile") {SaveOnFile(data:content, fileName: fileName)}
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
