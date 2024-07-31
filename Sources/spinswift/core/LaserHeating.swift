/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A class for managing laser heating
/// 
/// Laser heating interactions and atomic effects. 
/// - Author: Pascal Thibaudeau
/// - Date: 30/07/2025
/// - Version: 0.1

struct LaserExcitation : Codable {

    struct Temperatures : Codable {
        var Ions : Double
        var Electrons : Double
        var Spins : Double

        init(Ions: Double? = Double(), Electrons : Double? = Double(), Spins : Double? = Double()) {
            self.Ions = Ions!
            self.Electrons = Electrons!
            self.Spins = Spins!
        }
    }

    public struct Pulse : Codable {
        var Form : String
        var Fluence : Double
        var Duration : Double
        var Delay : Double

        init (Form : String? = "Gaussian", Fluence: Double? = Double(), Duration: Double? = Double(), Delay: Double? = Double()){
            self.Form = Form!
            self.Fluence = Fluence!
            self.Duration = Duration!
            self.Delay = Delay!
        }
    }

    public struct TTM : Codable {
        struct HeatCapacity : Codable {
            var Electron : Double
            var Phonon : Double
            var Spin : Double 

            init(Electron: Double? = Double(), Phonon: Double? = Double(), Spin:Double? = Double()){
                self.Electron = Electron!
                self.Phonon = Phonon!
                self.Spin = Spin!
            }
        }
        struct Coupling : Codable {
            var ElectronPhonon : Double
            var ElectronSpin : Double
            var PhononSpin : Double

            init(ElectronPhonon: Double? = Double(), ElectronSpin: Double? = Double(), PhononSpin: Double? = Double()){
                self.ElectronPhonon = ElectronPhonon!
                self.ElectronSpin = ElectronSpin!
                self.PhononSpin = PhononSpin!
            }
        }
        var EffectiveThickness : Double
        var InitialTemperature : Double

        init (EffectiveThickness: Double? = Double(), InitialTemperature: Double? = Double()) {
            self.EffectiveThickness = EffectiveThickness!
            self.InitialTemperature = InitialTemperature!
        }
    }

    var CurrentTime : Double

    init(CurrentTime: Double? = Double()) {
        self.CurrentTime = CurrentTime!
    }

    func ComputeInstantPower(Pulse : Pulse = Pulse(), TTM : TTM = TTM()) throws -> Double {
        var power = Double()

        switch Pulse.Form.lowercased() {
            case "gaussian":
                power = (Pulse.Fluence/(Pulse.Duration*TTM.EffectiveThickness))*exp(-((self.CurrentTime-Pulse.Delay)*(self.CurrentTime-Pulse.Delay))/(0.36*Pulse.Duration*Pulse.Duration))
            default: break
        }
        return power
    }
}
