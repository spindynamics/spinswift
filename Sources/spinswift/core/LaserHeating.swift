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
        var Electron : Double 
        var Phonon : Double 
        var Spin : Double 

        init(Electron : Double? = Double(), Phonon: Double? = Double(), Spin : Double? = Double()) {
            self.Electron = Electron!
            self.Phonon = Phonon!
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
        var Damping : Double
        var HeatCapacity : HeatCapacity?
        var Coupling : Coupling?

        init (EffectiveThickness: Double? = Double(), InitialTemperature: Double? = Double(), Damping: Double? = Double(), HeatCapacity: HeatCapacity? = HeatCapacity(), Coupling: Coupling? = Coupling()) {
            self.EffectiveThickness = EffectiveThickness!
            self.InitialTemperature = InitialTemperature!
            self.Damping = Damping!
            self.HeatCapacity = HeatCapacity!
            self.Coupling = Coupling!
        }
    }

    var CurrentTime : Double
    var temperatures : Temperatures
    var pulse : Pulse
    var ttm : TTM
    
    init(CurrentTime: Double? = Double(), temperatures: Temperatures? = Temperatures(), pulse: Pulse? = Pulse(), ttm : TTM? = TTM()) {
        self.CurrentTime = CurrentTime!
        self.temperatures = temperatures!
        self.pulse = pulse!
        self.ttm = ttm!
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

    func AdvanceTemperaturesGaussian(Δt : Double)  {
        
        let g: Double = self.ttm.Coupling!.ElectronPhonon
        let γ: Double = self.ttm.HeatCapacity!.Electron // Ce=gamma*Te
        let Cp: Double = self.ttm.HeatCapacity!.Phonon
        let τ_ls: Double = self.ttm.Damping
        let T_ref: Double = self.ttm.InitialTemperature

        let Te : Double = self.temperatures.Electron
        let Ti : Double = self.temperatures.Phonon

        var f0 : Double = ComputeInstantPower()
        f0 = f0/(γ*Te) // Laser power
        f0 -= (g/γ)*(1.0-(Ti/Te)) // f[0]=dTe/dt
        f0 -= (1.0/(τ_ls))*(Te-T_ref) // Newton cooling 
        self.temperatures.Electron += f0*Δt
        f0 = (g/Cp)*(Te-Ti) // f[1]=dTi/dt
        self.temperatures.Phonon += f0*Δt
    }

    func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}
