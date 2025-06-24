/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/****** Simulate Nickel bulk FCC *******/

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

//Initialze dLLB moments
let mm = Atom.Moments(spin:Vector3(1,0.0,0.0),sigma: Matrix3(1,0,0,0,0,0,0,0,0))


//Initialze Atom
let initials = InitialParam(name:"Ni", type: 1, moments: mm, g: 2.02, ℇ: D_0)

//Inititialze simulation program
let inisimulation = SimulationProgram.Inputs(T_initial: 0, T_step: 50, T_final: 1800, time_step: 1e-2, stop: 10, α: 0.1, thermostat: "classical")

//Initialze Crystal fromm atom
var Ni: [Atom] = [Atom(),Atom(),Atom(),Atom()]
Ni[0].position = Vector3(0.0, 0.0, 0.0)
Ni[1].position = Vector3(0.0, 0.5, 0.5)
Ni[2].position = Vector3(0.5, 0.0, 0.5)
Ni[3].position = Vector3(0.5, 0.5, 0.0) 

//Define the unit cell atoms (positions in the unit cell) 
let unitCellAtoms: [Atom] = Ni 

// Define the supercell dimensions 
let supercellDimensions = (x: 3, y: 3, z: 3) 

// Generate the crystal structure 
let crystalStructure = GenerateCrystalStructure(UCAtoms: unitCellAtoms, supercell: supercellDimensions, LatticeConstant: 0.35, InitParam: initials) 

//Define boundary conditions
let Boundaries = BoundaryConditions(BoxSize: 0.35*Vector3(3,3,3) ,PBC: "on")

//Set the desired iteraction (Here only exchange is used)
var h: Interaction = Interaction(crystalStructure)
.ExchangeField(typeI:1,typeJ:1,value:J_ij/ℏ.value,Rcut:0.25,BCs:Boundaries)
//.ZeemanField(Vector3(direction:"+z"), value: 1.5)

//Integrate the dLLB equation for each atom in thhe crystal
let sol: Integrate = Integrate(h)

//Simulation programe for which the integration will be done
var p = SimulationProgram(sol)
p.simulate(Program: "curie_temperature", IP: inisimulation)
/*******************************************************************************/


