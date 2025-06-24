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

        static func + (a: Temperatures, b: Temperatures) -> Temperatures {
            return Temperatures(Electron: (a.Electron+b.Electron), Phonon: (a.Phonon+b.Phonon), Spin: (a.Spin+b.Spin))
        }
        
        static func += (a: inout Temperatures, b: Temperatures) {
            var c: Temperatures = Temperatures()
            c = a + b
            a = c
        }

        static func * (a: Double, b: Temperatures) -> Temperatures {
            return Temperatures(Electron: a*(b.Electron), Phonon: a*(b.Phonon), Spin: a*(b.Spin))
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

    func ComputeInstantPower(time: Double) -> Double {
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


    private func computeCp(Temp: Double) -> Double {
        let TD: Double =  475
        let T: Double = Temp 
        var coef: Double = 0.0
        let u: Double = (TD/T)

        
       
        let x: [Double] = [-0.99726386, -0.98561151, -0.96476226, -0.93490608, -0.89632116, -0.84936761, -0.7944838,  -0.73218212, -0.66304427, -0.58771576, -0.50689991, -0.42135128, -0.3318686,  -0.23928736, -0.14447196, -0.04830767,  0.04830767,  0.14447196, 0.23928736,  0.3318686,   0.42135128,  0.50689991,  0.58771576,  0.66304427, 0.73218212,  0.7944838,   0.84936761,  0.89632116,  0.93490608,  0.96476226, 0.98561151,  0.99726386];

        let w: [Double] = [0.00701861, 0.01627439, 0.02539207, 0.03427386, 0.0428359,  0.05099806, 0.05868409, 0.06582222, 0.07234579, 0.0781939,  0.08331192, 0.08765209, 0.09117388, 0.0938444,  0.09563872, 0.09654009, 0.09654009, 0.09563872, 0.0938444,  0.09117388, 0.08765209, 0.08331192, 0.0781939,  0.07234579, 0.06582222, 0.05868409, 0.05099806, 0.0428359,  0.03427386, 0.02539207, 0.01627439, 0.00701861];

            for i: Int in 0..<32 {
                let xnew = 0.5*u*(x[i]+1)
                coef+=w[i]*((pow(xnew,4)*exp(xnew))/pow((exp(xnew)-1),2))
            }
            coef *= 0.5*u   
            coef *= 9*pow(u,-3)
        print(String(coef))
        return coef
    }

    private func LHS(time: Double, temperatures: Temperatures) -> Temperatures {
        let g: Double = self.ttm.Coupling!.ElectronPhonon
        let γ: Double = self.ttm.HeatCapacity!.Electron // Ce=gamma*Te
        let Cp: Double = self.ttm.HeatCapacity!.Phonon
        let τ_ls: Double = self.ttm.Damping
        let T_ref: Double = self.ttm.InitialTemperature

        let Te : Double = temperatures.Electron
        let Ti : Double = temperatures.Phonon

        var rate: Temperatures = LaserExcitation.Temperatures()

        var f0 : Double = ComputeInstantPower(time:time)
        f0 = f0/(γ*Te) // Laser power
        f0 -= (g/γ)*(1.0-(Ti/Te)) // f[0]=dTe/dt
        rate.Electron = f0 - (1.0/(τ_ls))*(Te-T_ref) // Newton cooling
        rate.Phonon = (g/Cp)*(Te-Ti) // f[1]=dTi/dt 
        return rate
    }

    private func LHS2TMvP(time: Double, temperatures: Temperatures) -> Temperatures {
        let g: Double = self.ttm.Coupling!.ElectronPhonon
        let γ: Double = self.ttm.HeatCapacity!.Electron // Ce=gamma*Te
        let Cp0: Double = self.ttm.HeatCapacity!.Phonon
        let τ_ls: Double = self.ttm.Damping
        let T_ref: Double = self.ttm.InitialTemperature
        let alp: Double = 797.8
        let epsl: Double = 1.934e-19
        let Kb: Double = 1.380649e-23
        let N_os: Double = 4.820e28
        let b: Double = 3.463e1 
        
        

        let Te : Double = temperatures.Electron
        let Ti : Double = temperatures.Phonon

        var rate: Temperatures = LaserExcitation.Temperatures()

        let x: Double = epsl/(Kb*Te)
        let gep: Double = g*(1/(Te+alp))
        let fx: Double = exp(x)-1
        let Ce: Double = 3*N_os*Kb*pow(x,2)*(exp(x)/pow(fx,2)) + b*Te + γ
        let Cp: Double = Cp0
        
        print("Gep"+String(gep))
        print("Ce"+String(Ce))
        print("Cp"+String(Cp))

        var f0 : Double = ComputeInstantPower(time:time)
        f0 = f0/(Ce) // Laser power
        f0 -= (gep/Ce)*(Te-Ti) // f[0]=dTe/dt
        rate.Electron = f0 - (1.0/(τ_ls))*(Te-T_ref) // Newton cooling
        rate.Phonon = (gep/Cp)*(Te-Ti) // f[1]=dTi/dt 
        return rate
    }

        private func LHS3TM(time: Double, temperatures: Temperatures) -> Temperatures {
        let gel: Double = self.ttm.Coupling!.ElectronPhonon
        let ges: Double = self.ttm.Coupling!.ElectronSpin
        let gsl: Double = self.ttm.Coupling!.PhononSpin
        let γ: Double = self.ttm.HeatCapacity!.Electron // Ce=gamma*Te
        let Cp: Double = self.ttm.HeatCapacity!.Phonon
        let Cs: Double = self.ttm.HeatCapacity!.Spin
        let τ_ls: Double = self.ttm.Damping
        let T_ref: Double = self.ttm.InitialTemperature

        let Te : Double = temperatures.Electron
        let Ti : Double = temperatures.Phonon
        let Ts : Double = temperatures.Spin

        var rate: Temperatures = LaserExcitation.Temperatures()

        var f0 : Double = ComputeInstantPower(time:time)
        f0 = f0/(γ*Te) // Laser power
        f0 -= (gel/γ)*(1.0-(Ti/Te)) // f[0]=dTe/dt
        f0 -= (ges/γ)*(1.0-(Ts/Te))
        rate.Electron = f0 - (1.0/(τ_ls))*(Te-T_ref) // Newton cooling
        rate.Phonon = (gel/Cp)*(Te-Ti) + (gsl/Cp)*(Ts-Ti)  // f[1]=dTi/dt 
        rate.Spin = (ges/(Cs*pow(Ts,1.5)))*(Te-Ts) + (gsl/(Cs*pow(Ts,1.5)))*(Ti-Ts)
        return rate
    }

    func AdvanceTemperaturesGaussian(method:String, Δt : Double)  {
          switch method.lowercased() {
            case "euler", "rk1":
                self.temperatures += Δt*LHS(time:self.CurrentTime,temperatures:self.temperatures)
            case "rk2":
                let k1: Temperatures = self.temperatures + 0.5*Δt*LHS(time:self.CurrentTime,temperatures:self.temperatures)
                self.temperatures += Δt*LHS(time:self.CurrentTime+0.5*Δt,temperatures:k1)
            case "rk4":
                let k1: Temperatures = LHS(time:self.CurrentTime,temperatures:self.temperatures)
                let k2: Temperatures = LHS(time:self.CurrentTime+0.5*Δt,temperatures:self.temperatures+0.5*Δt*k1)
                let k3: Temperatures = LHS(time:self.CurrentTime+0.5*Δt,temperatures:self.temperatures+0.5*Δt*k2)
                let k4: Temperatures = LHS(time:self.CurrentTime+Δt,temperatures:self.temperatures+Δt*k3)
                self.temperatures += (Δt/6)*(k1+2*k2+2*k3+k4)
            default: break
            }
    }

    func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}
