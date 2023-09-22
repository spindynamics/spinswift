import Foundation

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

var h1:Interaction = Interaction(MTJ[0])
.Zeeman(Vector3(direction:"+z"), value:0.1)
.Uniaxial(Vector3(direction:"+x"), value: 1)
.Dampening(0.1)

var h2:Interaction = Interaction(MTJ[2])
.Zeeman(Vector3(direction:"+z"), value:0.1)
.Uniaxial(Vector3(direction:"+x"), value: 1)
.Dampening(0.1)

print(try! h1.jsonify())


