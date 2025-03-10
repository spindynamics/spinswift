/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation
//import CGSL

// atomistic code syntax
/*
var a: Atom = Atom(name: PeriodicTable().Z_label("Iron"), type:1, position: Vector3(1,1,1), spin: Vector3(direction:"+y"), g:2)
var b: Atom = Atom(name: PeriodicTable().Z_label("Iron"), type:1, position: Vector3(0,1,2), spin: Vector3(direction:"+y"), g:2)

var atoms: [Atom] = [a,b]

atoms.forEach {
    print(try! $0.jsonify())
    }
*/

// device syntax

/*var MTJ:Stack = Stack()
MTJ.append(Magnetization(name: "Fe", type: 1, position: Vector3(0,0,0), spin: Vector3(direction:"+x"), g:2))
MTJ.append(Magnetization(name: "O", type: 2, position: Vector3(0,0,1), spin: Vector3(0,0,0), g:0))
MTJ.append(Magnetization(name: "Fe", type: 1, position: Vector3(0,0,2), spin: Vector3(direction:"+x"), g:2))

var h: Interaction = Interaction([MTJ[0],MTJ[2]])
h.ZeemanField(Vector3(direction:"+z"), value: 100000)
.UniaxialField(Vector3(direction:"+x"), value: 0.0)
//.ExchangeField(typeI:1,typeJ:1,value:1.0,Rcut:3)
h.Dampening(0.1)

//print(try! h.jsonify())
//let s: Integrate = Integrate(h)
//s.expLs(method:"euler",Δt:0.1)
//print(try! h.atoms[0].jsonify())
//print(Analysis(h.atoms).GetTemperature())
*/
/*
let pulse = LaserExcitation.Pulse(Form: "Gaussian", Fluence: 10.0, Duration: 60E-15, Delay: 0)
let Cp = LaserExcitation.TTM.HeatCapacity(Electron:6E3, Phonon:2.2E6)
let G = LaserExcitation.TTM.Coupling(ElectronPhonon: 2.5E17)
let ttm = LaserExcitation.TTM(EffectiveThickness: 1e-9, InitialTemperature: 300, Damping: 1E-12, HeatCapacity: Cp, Coupling: G)
let laser = LaserExcitation(temperatures: .init(Electron:ttm.InitialTemperature, Phonon:ttm.InitialTemperature), pulse:pulse,ttm:ttm)
print(laser.ComputeInstantPower(time:laser.CurrentTime))
*/
//let timestep = 1E-15
/*for _ in 0...1500 {
    laser.AdvanceTemperaturesGaussian(method:"rk4",Δt:timestep)
    laser.CurrentTime += timestep
    print(laser.CurrentTime,laser.temperatures.Electron,laser.temperatures.Phonon)

}
}*/

//var data = String()
//let mm = Atom.Moments(spin:Vector3(1,0.0,0.0),sigma: Matrix3(1,0,0,0,0,0,0,0,0))
/*
let Fe: Atom = Atom(name: "Fe", type: 1, position: Vector3(0,0,0), ω: -γ.value*1*Vector3(direction:"+z"), moments: mm, g:2)
var time:Double = 0
for _ in 0...400000{
//let s1: Integrate = Integrate(h)
Fe.AdvanceSpindLLB(method: "expIO1", Δt:1e-3, T: 10, α: 0.1)
//print(try! Fe.jsonify())
time+=1e-3
let length=Fe.spin.Norm()
data+=String(time)+" "+String(Fe.moments.spin.x)+" "+String(Fe.moments.spin.y)+" "+String(Fe.moments.spin.z)+" "+String(length)+"\n"
data+=String(time)+" "+String(Fe.spin.x)+" "+String(Fe.spin.y)+" "+String(Fe.spin.z)+" "+String(length)+"\n"
}
SaveOnFile(data: data, fileName: "dLLBnotemp")
*/
 
// Print the positions of atoms in the generated crystal structure. 
//IninitialzeAtomProperties(System: crystalStructure, name: "Ni", type: 1, moments: mm)
/*for atom in crystalStructure {data+=String(atom.name)+" "+String(atom.type)+" "+String(atom.position.x/0.35)+" "+String(atom.position.y/0.35)+" "+String(atom.position.z/0.35)+" "+String(atom.name)+"\n"
print(try! atom.jsonify())}
exit(-1)*/
//let mm = Atom.Moments(spin:Vector3(0,0.435,-0.9),sigma: Matrix3(0,0,0,0,0.19,-0.39,0,-0.39,0.81))
//print(String(crystalStructure.count))
//print(try! Ni.jsonify())
//SaveOnFile(data: data, fileName: "struct_NiFcc")
//let distance: Double = ComputeDistance(Boxsize: 0.35*Vector3(5,5,5), PBC: "true", atom1: crystalStructure[0], atom2: crystalStructure[25])
//print(String(distance))


/****** Simulate Nickel bulk FCC *******/
/*
let a: Double = 0.35
let Jexp: Double = 17.2
let J_ij: Double = 0.79*Jexp
let D_0: Double = 0.79*Jexp*a*a
//21.9611
//J_ij*a*a
let V_0: Double = a*a*a
let Em: Double = (D_0)*pow(((6*π*π)/V_0),2/3)
print(String(D_0))

//Define parameters 
let mm = Atom.Moments(spin:Vector3(1,0.0,0.0),sigma: Matrix3(1,0,0,0,0,0,0,0,0))
//let sp: Vector3 = Vector3(direction: "random")
//let sg: Matrix3 = sp ⊗ sp
//let mm = Atom.Moments(spin: sp, sigma: sg)
let initials = InitialParam(name:"Ni", type: 1, moments: mm, g: 2.02, ℇ: D_0)
let inisimulation = SimulationProgram.Inputs(T_initial: 0, T_step: 50, T_final: 800, time_step: 1e-2, stop: 100, α: 0.1, thermostat: "quantum")
var Ni: [Atom] = [Atom(),Atom(),Atom(),Atom()]
Ni[0].position = Vector3(0.0, 0.0, 0.0)
Ni[1].position = Vector3(0.0, 0.5, 0.5)
Ni[2].position = Vector3(0.5, 0.0, 0.5)
Ni[3].position = Vector3(0.5, 0.5, 0.0) 
//Define the unit cell atoms (positions in the unit cell). 
let unitCellAtoms: [Atom] = Ni 
// Define the supercell dimensions. 
let supercellDimensions = (x: 3, y: 3, z: 3) 
// Generate the crystal structure. 
let crystalStructure = GenerateCrystalStructure(UCAtoms: unitCellAtoms, supercell: supercellDimensions, LatticeConstant: 0.35, InitParam: initials) 
//Define boundary conditions 
let Boundaries = BoundaryConditions(BoxSize: 0.35*Vector3(3,3,3) ,PBC: "on")

var h: Interaction = Interaction(crystalStructure)
.ExchangeField(typeI:1,typeJ:1,value:J_ij/ℏ.value,Rcut:0.25,BCs:Boundaries)
//.ZeemanField(Vector3(direction:"+z"), value: 1.5)

//print(try! h.jsonify())

let sol: Integrate = Integrate(h)
//sol.Evolve(stop: 1e-1, Δt: 1e-5, method: "rk4", file: "Output_atms", Eqs: "dLLB")

//print(try! h.jsonify())
var p = SimulationProgram(sol)
p.simulate(Program: "curie_temperature", IP: inisimulation)
/*******************************************************************************/
*/

/*
/****** Simulate Iron bulk BCC *******/

//compute Magnon energy

let a: Double = 0.284
let Jexp: Double = 38
let J_ij: Double = 0.766*Jexp
let D_0: Double = 0.766*Jexp*a*a
let V_0: Double = a*a*a
let Em: Double = (D_0)*pow(((6*π*π)/V_0),2/3)
print(String(Em))

//Define prameters
let mm = Atom.Moments(spin:Vector3(1,0.0,0.0),sigma: Matrix3(1,0,0,0,0,0,0,0,0))
let initials = InitialParam(name:"Fe", type: 1, moments: mm, g: 2.02, ℇ: D_0)
let inisimulation = SimulationProgram.Inputs(T_initial: 50, T_step: 20, T_final: 1200, time_step: 1e-3, stop: 10, α: 0.05, thermostat: "quantum")
var Fe: [Atom] = [Atom(),Atom()]
Fe[0].position = Vector3(0.0, 0.0, 0.0)
Fe[1].position = Vector3(0.5, 0.5, 0.5)
//Define the unit cell atoms (positions in the unit cell). 
let unitCellAtoms: [Atom] = Fe 
// Define the supercell dimensions. 
let supercellDimensions = (x: 3, y: 3, z: 3) 
// Generate the crystal structure. 
let crystalStructure = GenerateCrystalStructure(UCAtoms: unitCellAtoms, supercell: supercellDimensions, LatticeConstant: 0.284, InitParam: initials)
//Define boundary conditions 
let Boundaries = BoundaryConditions(BoxSize: 0.284*Vector3(3,3,3) ,PBC: "on")

var h: Interaction = Interaction(crystalStructure)
.ExchangeField(typeI:1,typeJ:1,value:J_ij/ℏ.value,Rcut:0.246,BCs:Boundaries)


//.ZeemanField(Vector3(direction:"+z"), value: 0.01)

//print(try! h.jsonify())

let sol: Integrate = Integrate(h)
//sol.Evolve(stop: 1e-1, Δt: 1e-5, method: "rk4", file: "Output_atms", Eqs: "dLLB")

//print(try! h.jsonify())

var p = SimulationProgram(sol)
p.simulate(Program: "optical_pulse", IP: inisimulation)
/*******************************************************************************/
*/

/*
/****** Simulate Cobalt bulk FCC *******/

//compute Magnon energy

let a: Double = 0.352
let Jexp: Double = 38
let J_ij: Double = 0.79*Jexp
let D_0: Double = 0.79*Jexp*a*a
//let D_0: Double = 384*1e-2 
let D_1: Double = J_ij*a*a
let V_0: Double = a*a*a
let Em: Double = (D_0)*pow(((6*π*π)/V_0),2/3)
let Em1: Double = (D_1)*pow(((6*π*π)/V_0),2/3)
print(String(Em))
print(String(Em1))

//Define parameters 
let mm = Atom.Moments(spin:Vector3(1,0.0,0.0),sigma: Matrix3(1,0,0,0,0,0,0,0,0))
let initials = InitialParam(name:"Co", type: 1, moments: mm, g: 2.02, ℇ: D_0)
let inisimulation = SimulationProgram.Inputs(T_initial: 0, T_step: 100, T_final: 100, time_step: 1e-3, stop: 10, α: 0.015, thermostat: "quantum")
var Co: [Atom] = [Atom(),Atom(),Atom(),Atom()]
Co[0].position = Vector3(0.0, 0.0, 0.0)
Co[1].position = Vector3(0.0, 0.5, 0.5)
Co[2].position = Vector3(0.5, 0.0, 0.5)
Co[3].position = Vector3(0.5, 0.5, 0.0) 
//Define the unit cell atoms (positions in the unit cell). 
let unitCellAtoms: [Atom] = Co 
// Define the supercell dimensions. 
let supercellDimensions = (x: 3, y: 3, z: 3) 
// Generate the crystal structure. 
let crystalStructure = GenerateCrystalStructure(UCAtoms: unitCellAtoms, supercell: supercellDimensions, LatticeConstant: 0.352, InitParam: initials) 
//Define boundary conditions 
let Boundaries = BoundaryConditions(BoxSize: 0.352*Vector3(3,3,3) ,PBC: "on")

var h: Interaction = Interaction(crystalStructure)
.ExchangeField(typeI:1,typeJ:1,value:J_ij/ℏ.value,Rcut:0.25,BCs:Boundaries)


//.ZeemanField(Vector3(direction:"+z"), value: 0.01)

//print(try! h.jsonify())

let sol: Integrate = Integrate(h)
//sol.Evolve(stop: 1e-1, Δt: 1e-5, method: "rk4", file: "Output_atms", Eqs: "dLLB")

//print(try! h.jsonify())
var p = SimulationProgram(sol)
p.simulate(Program: "optical_pulse", IP: inisimulation)
/*******************************************************************************/
*/

/*
/****** Simulate Gadolinium bulk FCC 4.24264068712* *******/

//compute Magnon energy
let a: Double = 0.363
let J_ij: Double = 0.79*7.88
let D_0: Double = J_ij*a*a
let V_0: Double = a*a*a
let Em: Double = (D_0)*pow(((6*π*π)/V_0),2/3)
print(String(Em))

//Define parameters 
let mm = Atom.Moments(spin:Vector3(1,0.0,0.0),sigma: Matrix3(1,0,0,0,0,0,0,0,0))
let initials = InitialParam(name:"Gd", type: 1, moments: mm, g: 2.02, ℇ: D_0)
let inisimulation = SimulationProgram.Inputs(T_initial: 0, T_step: 5, T_final: 320, time_step: 1e-2, stop: 10, α: 0.1, thermostat: "quantum")
var Gd: [Atom] = [Atom(),Atom(),Atom(),Atom()]
Gd[0].position = Vector3(0.0, 0.0, 0.0)
Gd[1].position = Vector3(0.0, 0.5, 0.5)
Gd[2].position = Vector3(0.5, 0.0, 0.5)
Gd[3].position = Vector3(0.5, 0.5, 0.0) 
//Define the unit cell atoms (positions in the unit cell). 
let unitCellAtoms: [Atom] = Gd 
// Define the supercell dimensions. 
let supercellDimensions = (x: 3, y: 3, z: 3) 
// Generate the crystal structure. 
let crystalStructure = GenerateCrystalStructure(UCAtoms: unitCellAtoms, supercell: supercellDimensions, LatticeConstant: 0.363, InitParam: initials) 
//Define boundary conditions 
let Boundaries = BoundaryConditions(BoxSize: 0.363*Vector3(3,3,3) ,PBC: "on")

var h: Interaction = Interaction(crystalStructure)
.ExchangeField(typeI:1,typeJ:1,value:J_ij/ℏ.value,Rcut:0.257,BCs:Boundaries)


//.ZeemanField(Vector3(direction:"+z"), value: 0.01)

//print(try! h.jsonify())

let sol: Integrate = Integrate(h)
//sol.Evolve(stop: 1e-1, Δt: 1e-5, method: "rk4", file: "Output_atms", Eqs: "dLLB")

//print(try! h.jsonify())
var p = SimulationProgram(sol)
p.simulate(Program: "curie_temperature", IP: inisimulation)
/*******************************************************************************/
*/


/****** Simulate FeGd bulk alloy *******/

//Gadolinum Paramertes
let TcGd: Double = 292.5 //experimental
let a1: Double = 0.363
let J_GdGd: Double = 0.79*7.88
let D_01: Double = J_GdGd*a1*a1
let V_01: Double = a1*a1*a1
let Dcut1: Double = D_01*pow(1-(292.499/TcGd),0.33333333333)
let b1: Double = 1.5*2.85e-3     // Van Hove singularity fit

//Iron Parameters

let TcFe: Double = 1044 //experimental
let a2: Double = 0.284
let J_FeFe: Double = 0.766*38
let D_02: Double = J_FeFe*a2*a2
let V_02: Double = a2*a2*a2
let Dcut2: Double = D_02*pow(1-(1043.99/TcFe),0.33333333333)
let b2: Double = 2.85e-3     // Van Hove singularity fit

//Intelattice coupling 

let J_FeGd: Double = -6.8

//Define parameters 
let mm = Atom.Moments(spin:Vector3(0.0,0.0,1),sigma: Matrix3(0,0,0,0,0,0,0,0,1))
let mm2 = Atom.Moments(spin:Vector3(0.0,0.0,-1),sigma: Matrix3(0,0,0,0,0,0,0,0,1))
let initials1 = InitialParam(name:"Fe", type: 1, moments: mm, g: 2.02, ℇ: D_02, Vat: V_02, Dref: Dcut2, vanHove: b2)
let initials2 = InitialParam(name:"Gd", type: 2, moments: mm2, g: 2.02, ℇ: D_01, Vat: V_01, Dref: Dcut1, vanHove: b1)
let inisimulation = SimulationProgram.Inputs(T_initial: 0, T_step: 25, T_final: 500, time_step: 1e-3, stop: 20, α: 0.03, thermostat: "quantum")
var Fe: [Atom] = [Atom(),Atom(),Atom(),Atom()]
Fe[0].position = Vector3(0.0, 0.0, 0.0)
Fe[1].position = Vector3(0.0, 0.5, 0.5)
Fe[2].position = Vector3(0.5, 0.0, 0.5)
Fe[3].position = Vector3(0.5, 0.5, 0.0) 
//Define the unit cell atoms (positions in the unit cell). 
let unitCellAtoms: [Atom] = Fe 
// Define the supercell dimensions. 
let supercellDimensions = (x: 3, y: 3, z: 3) 
// Generate the crystal structure. 
let crystalStructure = GenerateCrystalStructure(UCAtoms: unitCellAtoms, supercell: supercellDimensions, LatticeConstant: 0.363, InitParam: initials1) 
//Define boundary conditions 
let Boundaries = BoundaryConditions(BoxSize: 0.363*Vector3(3,3,3) ,PBC: "on")
//Alloy
let Alloy = substituteRandomAtoms(structure: crystalStructure, InitParam: initials2, Percentage: 50) 

//for i in 0..<Alloy.count {print(String(Alloy[i].type))}

var h: Interaction = Interaction(Alloy)
//.ExchangeField(typeI:1,typeJ:1,value:J_FeFe/ℏ.value,Rcut:0.257,BCs:Boundaries)
//.ExchangeField(typeI:2,typeJ:2,value:J_GdGd/ℏ.value,Rcut:0.257,BCs:Boundaries)
.ExchangeField(typeI:1,typeJ:2,value:J_FeGd/ℏ.value,Rcut:0.257,BCs:Boundaries)
//.UniaxialField(Vector3(direction:"+z"), value: 0.050369)
.ZeemanField(Vector3(direction:"+z"), value: -1.5)

//print(try! h.jsonify())

let sol: Integrate = Integrate(h)
//sol.Evolve(stop: 1e-1, Δt: 1e-5, method: "rk4", file: "Output_atms", Eqs: "dLLB")

//print(try! h.jsonify())
var p = SimulationProgram(sol)
p.simulate(Program: "optical_pulse", IP: inisimulation)
/*******************************************************************************/
