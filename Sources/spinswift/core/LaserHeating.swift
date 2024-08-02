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

class LaserExcitation : Codable {

    struct Temperatures : Codable {
        var Phonon : Double
        var Electron : Double
        var Spin : Double

        init(Phonon: Double? = Double(), Electron : Double? = Double(), Spin : Double? = Double()) {
            self.Phonon = Phonon!
            self.Electron = Electron!
            self.Spin = Spin!
        }
    }

    struct Pulse : Codable {
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

    struct TTM : Codable {

        typealias HeatCapacity = Temperatures

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
        var HeatCapacity : HeatCapacity?
        var Coupling : Coupling?

        init (EffectiveThickness: Double? = Double(), InitialTemperature: Double? = Double(), HeatCapacity: HeatCapacity? = HeatCapacity(), Coupling: Coupling? = Coupling()) {
            self.EffectiveThickness = EffectiveThickness!
            self.InitialTemperature = InitialTemperature!
            self.HeatCapacity = HeatCapacity!
            self.Coupling = Coupling!
        }
    }

    var CurrentTime : Double
    var pulse : Pulse
    var ttm : TTM
    var temperatures : Temperatures
    
    init(CurrentTime: Double? = Double(), pulse: Pulse? = Pulse(), ttm : TTM? = TTM(), temperatures: Temperatures? = Temperatures()) {
        self.CurrentTime = CurrentTime!
        self.pulse = pulse!
        self.ttm = ttm!
        self.temperatures = temperatures!
    }

    func ComputeInstantPower() -> Double {
        var power = Double()

        switch self.pulse.Form.lowercased() {
            case "gaussian":
                let Φ = self.pulse.Fluence
                let σ = self.pulse.Duration
                let δ = self.pulse.Delay
                let ζ = self.ttm.EffectiveThickness
                let t = self.CurrentTime
                power = (Φ/(σ*ζ))*exp(-((t-δ)*(t-δ))/(0.36*σ*σ))
            default: break
        }
        return power
    }

    func ODEGaussian(t:Double, y:UnsafePointer<Double>, f:UnsafePointer<Double>, params:UnsafePointer<Double> ) -> Int {
        let Φ: Double = params[0]
        let σ: Double = params[1]
        let g: Double = params[2]
        let γ: Double = params[3]
        let Cp: Double = params[4]
        let t_ls: Double = params[5]
        let τ_ls: Double = params[6]
        let T_ref: Double = params[7]
        let t_FM: Double  = params[8]

        let pulse: Pulse = LaserExcitation.Pulse(Form:"Gaussian",Fluence:Φ,Duration:σ,Delay:t_ls)
        let ttm: TTM = LaserExcitation.TTM(EffectiveThickness:t_FM)

        var f0 : Double = LaserExcitation(CurrentTime:t,pulse:pulse,ttm:ttm).ComputeInstantPower()
        f0 = f0/(γ*y[0]) // Laser power
        f0 -= (g/γ)*(1.0-(y[1]/y[0])) // f[0]=dTe/dt
        f0 -= (1.0/(τ_ls))*(y[0]-T_ref) // Newton cooling 
        var f : [Double] = [Double()]
        f.append(f0)
        f0 = (g/Cp)*(y[0]-y[1]) // f[1]=dTi/dt
        f.append(f0)

        return 0
    }

    func ODEJACGaussian(t:Double, y:UnsafePointer<Double>, dfdy:UnsafePointer<Double>, dfdt:UnsafePointer<Double>, params:UnsafePointer<Double> ) -> Int {
        return 0
    }

    func UpdateTemperatures() {
    }

    func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}
