/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// This class for managing The simulation programs of the Spinswift code.
/// All simulation programs are created and managed in this class. The list of available simulation programs is bellow
/// - Author: Mouad Fattouhi
/// - Date: 02/09/2024
/// - Version: 0.1

/* List of simulation programs:
   1) Curie_Temperature: Simulates multi-spin dynamics with a temperature sweep to determine the Curie curve.
   2) Optical_Pulse: Simulates laser pulse excitation using 2-Temperature (2TM) or 3-Temperature (3TM) models.
   3) Time_Dynamics: Simulates individual spin dynamics under user-defined magnetic fields and interactions.
   4) Paramagnetic_Spins: Simulates multi-spin systems neglecting exchange interactions.
   5) Macrospin: Simplified single-particle model (partially implemented).
*/

public class SimulationProgram: Codable {

  public var I: Integrate

  public init(_ I: Integrate = Integrate()) {
    self.I = I
  }

  public struct Inputs: Codable {
    public var method: String
    public var initialTemperature: Double
    public var ΔT: Double
    public var finalTemperature: Double
    public var finalTime: Double
    public var Δt: Double
    public var thermostat: Thermostat

    public init(
      method: String? = String(),
      initialTemperature: Double? = Double(),
      ΔT: Double? = Double(), finalTemperature: Double? = Double(),
      Δt: Double? = Double(), finalTime: Double? = Double(),
      thermostat: Thermostat? = Thermostat()
    ) {
      self.method = method!
      self.initialTemperature = initialTemperature!
      self.ΔT = ΔT!
      self.finalTemperature = finalTemperature!
      self.Δt = Δt!
      self.finalTime = finalTime!
      self.thermostat = thermostat!
    }
  }

  public func simulate(Program: String? = nil, IP: Inputs) {
    switch Program?.lowercased() {
    case "curie_temperature"?:
      self.curieTemp(Initialize: IP)
    case "optical_pulse"?:
      self.opticalPulse(IP: IP)
    case "time_dynamics"?:
      self.timeDynamics(Initialize: IP)
    case "paramagnetic_spins"?: break
    //self.Paramagnet(finalTime: finalTime, Δt:Initialize.Δt)
    default:
      print(
        "Program not found. Choose one of the available programs:\ncurie_temperature\noptical_pulse\ntime_dynamics\nparamagnetic_spins\nmacrospin"
      )
    }
  }

  //Curie temperature program

  public func curieTemp(Initialize: Inputs) {
    var T: Double = Initialize.initialTemperature
    let finalTime: Double = Initialize.finalTime
    let Δt: Double = Initialize.Δt
    let finalTemperature: Double = Initialize.finalTemperature
    let ΔT: Double = Initialize.ΔT
    let thermostat: Thermostat = Initialize.thermostat

    let analysis = Analysis(I.h.atoms)
    let streamer = try? FileStreamer(fileName: "Output_CurieTemp")

    while T < finalTemperature {
      let Fn: String = "CT_T_" + String(format: "%.0f", T)
      thermostat.T = T
      I.evolve(
        finalTime: finalTime, Δt: Δt, method: "dLLB_rk4", file: Fn, thermostat: thermostat)
      let summary = analysis.getMagnetizationSummary()
      let χ: Matrix3 = analysis.getSusceptibility()
      let line =
        "\(T)\t\(summary.vector.x)\t\(summary.vector.y)\t\(summary.vector.z)\t\(summary.length)\t\(χ.xx)\t\(χ.yy)\t\(χ.zz)\t\(χ.xy)\t\(χ.yz)\t\(χ.zx)"
      streamer?.writeLine(line)
      T += ΔT
    }
    streamer?.close()
  }

  //Laser Pulse program

  public func opticalPulse(IP: Inputs) {
    let pulse: LaserExcitation.Pulse =
      LaserExcitation.Pulse(Form: "Gaussian", Fluence: 32.5, Duration: 60E-15, Delay: 5e-12)
    let Cp: LaserExcitation.TTM.HeatCapacity =
      LaserExcitation.TTM.HeatCapacity(Electron: 7E3, Phonon: 3e6)
    let G: LaserExcitation.TTM.Coupling = LaserExcitation.TTM.Coupling(ElectronPhonon: 60e17)
    let ttm: LaserExcitation.TTM = LaserExcitation.TTM(
      EffectiveThickness: 15E-9, InitialTemperature: 82, Damping: 5E-12, HeatCapacity: Cp,
      Coupling: G)
    let laser: LaserExcitation = LaserExcitation(
      temperatures: .init(
        Electron: ttm.InitialTemperature, Phonon: ttm.InitialTemperature,
        Spin: ttm.InitialTemperature), pulse: pulse, ttm: ttm)
    let Δt: Double = IP.Δt
    var sl1: [Atom] = []
    var sl2: [Atom] = []

    for i: Atom in I.h.atoms {
      if i.type == 1 {
        sl1.append(i)
      } else {
        sl2.append(i)
      }
    }

    let analysis = Analysis(I.h.atoms)
    let analysisSl1 = Analysis(sl1)
    let analysisSl2 = Analysis(sl2)

    let streamer = try? FileStreamer(fileName: "AOS_FeGd_25pct")

    while laser.CurrentTime < IP.finalTime * 1E-12 {
      laser.AdvanceTemperaturesGaussian(method: "euler", Δt: Δt * 1E-12)
      laser.CurrentTime += Δt * 1E-12
      IP.thermostat.T = laser.temperatures.Electron
      for a: Atom in I.h.atoms {
        a.advanceMoments(
          method: "dLLB_rk4", Δt: Δt, thermostat: IP.thermostat)
      }

      //laser.temperatures.Electron
      let m: Vector3 = analysis.getMagnetization()
      let m1: Vector3 = analysisSl1.getMagnetization()
      let m2: Vector3 = analysisSl2.getMagnetization()

      let line =
        "\(laser.CurrentTime)\t\(m1.z)\t\(m2.z)\t\(m.z)\t\(laser.ComputeInstantPower(time: laser.CurrentTime))\t\(laser.temperatures.Electron)\t\(laser.temperatures.Phonon)\t\(laser.temperatures.Spin)"
      streamer?.writeLine(line)

      self.I.h.update()
    }
    streamer?.close()

  }

  public func timeDynamics(Initialize: Inputs) {
    let method: String = Initialize.method
    let T: Double = Initialize.initialTemperature
    let Fn: String = "Dy_T_" + String(format: "%.0f", T) + "a_1e-2"
    let finalTime: Double = Initialize.finalTime
    let Δt: Double = Initialize.Δt
    let thermostat: Thermostat = Initialize.thermostat

    I.evolve(
      finalTime: finalTime, Δt: Δt, method: method, file: Fn, thermostat: thermostat)
  }
}
