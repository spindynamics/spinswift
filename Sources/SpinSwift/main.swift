/*
 //  Copyright (C) 2017 Pascal Thibaudeau.
 //
 // This software is a computer program whose purpose is Spinswift.
 //
 // This software is governed by the CeCILL license under French law and
 // abiding by the rules of distribution of free software. You can use,
 // modify and/ or redistribute the software under the terms of the CeCILL
 // license as circulated by CEA, CNRS and INRIA at the following URL
 // "http://www.cecill.info".
 //
 // As a counterpart to the access to the source code and rights to copy,
 // modify and redistribute granted by the license, users are provided only
 // with a limited warranty and the software's author, the holder of the
 // economic rights, and the successive licensors have only limited
 // liability.
 //
 // In this respect, the user's attention is drawn to the risks associated
 // with loading, using, modifying and/or developing or reproducing the
 // software by the user in light of its specific status of free software,
 // that may mean that it is complicated to manipulate, and that also
 // therefore means that it is reserved for developers and experienced
 // professionals having in-depth computer knowledge. Users are therefore
 // encouraged to load and test the software's suitability as regards their
 // requirements in conditions enabling the security of their systems and/or
 // data to be ensured and, more generally, to use and operate it in the
 // same conditions as regards security.
 //
 // The fact that you are presently reading this means that you have had
 // knowledge of the CeCILL license and that you accept its terms.
 //
 //  main.swift
 //  Spinswift
 //
 //  Created by Pascal Thibaudeau on 24/03/2017.
 */

import SpinSwiftCore

// setup mesh and material constants
let n   = [2, 2, 2]  // grid
let J   = 0.1 // eV exchange
let α   = 0.2 // Gilbert Damping
let κ   = 0.1 // eV anisotropy constant

let region = Region(p1:Vector3(), p2:Vector3(1,1,1))
let g = Geometry(region: region, cell: n, pbc:[true,true,true])
let N1 = Neighbors(geometry: g, radius:0.5)

print(N1.list)

var a: [Atom] = Array(repeating: 0, count: g.r.count).map { _ in return Atom(spin:Vector3(direction:"+z",normalize:true), name:"Cobalt", type: 1)}

var h=Hamiltonian(fromAtoms: a, fromGeometry: g)

h.externalDCField(value: Vector3(x:10))
h.uniaxialAnisotropyField(value: κ, axis: Vector3(y:1))
h.exchangeField(value: J, n: N1.list)
h.damping(value: α)

h.evolve(stop:10, timestep:0.1, method:"euler", file:"test_euler")