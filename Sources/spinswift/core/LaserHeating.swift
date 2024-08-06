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
        /// the electron temperature
        var Electron : Double 
        /// the phonon or lattice temperature
        var Phonon : Double 
        /// the spin temperature
        var Spin : Double 

        init(Electron : Double? = Double(), Phonon: Double? = Double(), Spin : Double? = Double()) {
            self.Electron = Electron!
            self.Phonon = Phonon!
            self.Spin = Spin!
        }

        /// addition of two temperatures
        static func + (a: Temperatures, b: Temperatures) -> Temperatures {
            return Temperatures(Electron: (a.Electron+b.Electron), Phonon: (a.Phonon+b.Phonon), Spin: (a.Spin+b.Spin))
        }
        /// subtraction of two temperatures
        static func - (a: Temperatures, b: Temperatures) -> Temperatures {
            return Temperatures(Electron: (a.Electron-b.Electron), Phonon: (a.Phonon-b.Phonon), Spin: (a.Spin-b.Spin))
        }
        /// addition and affectation of two temperatures
        static func += (a: inout Temperatures, b: Temperatures) {
            var c: Temperatures = Temperatures()
            c = a + b
            a = c
        }
        /// multiplication by a single scalar each of the temperatures
        static func * (a: Double, b: Temperatures) -> Temperatures {
            return Temperatures(Electron: a*(b.Electron), Phonon: a*(b.Phonon), Spin: a*(b.Spin))
        }
    }

    struct Pulse : Codable {
        /// nature of the laser pulse, either Gaussian or Triangle
        var Form : String
        /// Laser fluence in J/cm²
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
    /// Output temperatures for the 3 or 2 temperatures model
    var temperatures : Temperatures
    /// Laser pulse parameters
    var pulse : Pulse
    /// Physical content of the 2-3 temperatures model
    var ttm : TTM
    /// Current time when the temperatures are evaluated
    var time : Double

    /**
        Initializes a new laser excitation with the provided parts and specifications.

        - Parameters:
            - time: Current time when the temperatures are evaluated
            - temperatures : structure of electron, phonon and spin temperatures
            - pulse : parameters structure of the laser pulse
            - ttm : structure of the physical content of the 2-3 temperatures model

        - Returns: A new laser excitation
    */
    
    init(time: Double? = Double(), temperatures: Temperatures? = Temperatures(), pulse: Pulse? = Pulse(), ttm : TTM? = TTM()) {
        self.time = time!
        self.temperatures = temperatures!
        self.pulse = pulse!
        self.ttm = ttm!
    }

    /// Compute the absorbed laser power in W/cm³
    func Power(time: Double) -> Double {
        var power = Double()

        switch self.pulse.Form.lowercased() {
            case "gaussian":
                let Φ = self.pulse.Fluence
                let σ = self.pulse.Duration
                let δ = self.pulse.Delay
                let ζ = self.ttm.EffectiveThickness
                power = (Φ/(σ*ζ))*exp(-((time-δ)*(time-δ))/(0.36*σ*σ))
            default: break
        }
        return power
    }

    /// Compute the rate of variation of the temperatures in K/s
    private func LHS(time: Double, temperatures: Temperatures) -> Temperatures {
        let Cep: Double = self.ttm.Coupling!.ElectronPhonon
        let Ces: Double = self.ttm.Coupling!.ElectronSpin
        let Cps: Double = self.ttm.Coupling!.PhononSpin
        let γ: Double = self.ttm.HeatCapacity!.Electron // Ce=gamma*Te
        let Cp: Double = self.ttm.HeatCapacity!.Phonon
        let Cs: Double = self.ttm.HeatCapacity!.Spin
        let τ_ls: Double = self.ttm.Damping
        let T_ref: Double = self.ttm.InitialTemperature

        let Te : Double = temperatures.Electron
        let Tp : Double = temperatures.Phonon
        let Ts : Double = temperatures.Spin

        var rate: Temperatures = LaserExcitation.Temperatures()

        var f0 : Double = Power(time:time)
        f0 = f0/(γ*Te) // Laser power
        f0 -= (Cep/γ)*(1.0-(Tp/Te))
        f0 -= (Ces/γ)*(1.0-(Ts/Te))// f[0]=dTe/dt
        rate.Electron = f0 - (1.0/(τ_ls))*(Te-T_ref) // Newton cooling
        rate.Phonon = (Cep/Cp)*(Te-Tp)+(Cps/Cp)*(Ts-Tp) // f[1]=dTp/dt
        rate.Spin = (Ces/Cs)*(Te-Ts)+(Cps/Cs)*(Tp-Ts) // f[2]=dTs/dt 
        return rate
    }

    func AdvanceTemperaturesGaussian(method:String, Δt : Double)  {
          switch method.lowercased() {
            case "euler", "rk1":
                self.temperatures += Δt*LHS(time:self.time,temperatures:self.temperatures)
            case "rk2":
                let k1: Temperatures = self.temperatures + 0.5*Δt*LHS(time:self.time,temperatures:self.temperatures)
                self.temperatures += Δt*LHS(time:self.time+0.5*Δt,temperatures:k1)
            case "rk4":
                let k1: Temperatures = LHS(time:self.time,temperatures:self.temperatures)
                let k2: Temperatures = LHS(time:self.time+0.5*Δt,temperatures:self.temperatures+0.5*Δt*k1)
                let k3: Temperatures = LHS(time:self.time+0.5*Δt,temperatures:self.temperatures+0.5*Δt*k2)
                let k4: Temperatures = LHS(time:self.time+Δt,temperatures:self.temperatures+Δt*k3)
                self.temperatures += (Δt/6)*(k1+2*k2+2*k3+k4)
            default: break
            }   
    }

    func EstimateTimestep(factor:Double) -> Double {
        let temp = LHS(time:self.time,temperatures:self.temperatures)
        let array = [abs(temp.Electron),abs(temp.Phonon),abs(temp.Spin)]
        return factor/(array.max()!)
    }

    func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}
