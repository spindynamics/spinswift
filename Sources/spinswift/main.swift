/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation
import CGSL

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

var MTJ:Stack = Stack()
MTJ.append(Magnetization(name: "Fe", type: 1, position: Vector3(0,0,0), spin: Vector3(direction:"+x"), g:2))
MTJ.append(Magnetization(name: "O", type: 2, position: Vector3(0,0,1), spin: Vector3(0,0,0), g:0))
MTJ.append(Magnetization(name: "Fe", type: 1, position: Vector3(0,0,2), spin: Vector3(direction:"+x"), g:2))

var h: Interaction = Interaction([MTJ[0],MTJ[2]])
.ZeemanField(Vector3(direction:"+z"), value: 0.1)
.UniaxialField(Vector3(direction:"+x"), value: 0.0)
//.ExchangeField(typeI:1,typeJ:1,value:1.0,Rcut:3)
.Dampening(0.1)

//print(try! h.jsonify())
let s: Integrate = Integrate(h)
s.expLs(method:"euler",Δt:0.1)
//print(try! h.atoms[0].jsonify())
//print(Analysis(h.atoms).GetTemperature())

let pulse = LaserExcitation.Pulse(Form: "Gaussian", Fluence: 10.0, Duration: 60E-15, Delay: 0)
let Cp = LaserExcitation.TTM.HeatCapacity(Electron:6E3, Phonon:2.2E6)
let G = LaserExcitation.TTM.Coupling(ElectronPhonon: 2.5E17)
let ttm = LaserExcitation.TTM(EffectiveThickness: 1e-9, InitialTemperature: 300, Damping: 1E-12, HeatCapacity: Cp, Coupling: G)
let laser = LaserExcitation(temperatures: .init(Electron:ttm.InitialTemperature, Phonon:ttm.InitialTemperature), pulse:pulse,ttm:ttm)
print(laser.ComputeInstantPower(time:laser.CurrentTime))

let timestep = 1E-15
for _ in 0...1500 {
    laser.AdvanceTemperaturesGaussian(method:"rk4",Δt:timestep)
    laser.CurrentTime += timestep
    print(laser.CurrentTime,laser.temperatures.Electron,laser.temperatures.Phonon)
}

print("==============================================")
//Test fucntion print matrix
var S:Matrix3 = Matrix3(fill:"antisym")
print("The S matrix")
S.Print()

print("==============================================")

//Test fuction Double*Matrix
var X:Matrix3 = 5.0*S
print("The X matrix = 5*S")
X.Print()

print("==============================================")

//Test fuction Matrix*Matrix
var SX: Matrix3 = S * X
print("The S matrix the X matrix = the SX matrix")
SX.Print() 

print("==============================================")

//Test fuction Trace of matrix
var Tr: Double = SX.Trace()
print("Trace(SX)=",Tr)

print("==============================================")

//Test fuction Determinant of matrix
var Det: Double = SX.Det()
print("Det(SX)=",Det)

print("==============================================")

var trsSX: Matrix3 = SX.Transpose()
print("The transpose of the SX matrix")
trsSX.Print()

print("==============================================")

var CofSX: Matrix3 = SX.Cofactor()
print("The cofactor of the SX matrix")
CofSX.Print()

print("==============================================")

var AdjSX: Matrix3 = SX.Adjoint()
print("The Adjoint of the SX matrix")
AdjSX.Print()

print("==============================================")

var InvSX: Matrix3 = SX.Inverse()
print("The Inverse of the SX matrix")
InvSX.Print()

print("==============================================")

var v: Vector3 = Vector3(1.0,0.0,1.0)

var Axv: Matrix3 = SX × v
print("a vector v =(1,0,1) cross the matrix SX")
Axv.Print()

print("==============================================")

var powSX: Matrix3 = SX^3
print("The power of the SX matrix")
powSX.Print()
