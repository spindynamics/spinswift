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

let pulse = LaserExcitation.Pulse(Form: "Triangle", Fluence: 10, Duration: 5E-15, Delay: 0)
let ttm = LaserExcitation.TTM(EffectiveThickness: 1e-9)
print(LaserExcitation().ComputeInstantPower(Pulse:pulse,TTM:ttm))
