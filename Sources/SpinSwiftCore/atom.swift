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
//  atom.swift
//  Spinswift
//
//  Created by Pascal Thibaudeau on 24/03/2017.
*/

import Foundation

public class Atom {
    public var spin: Vector3 // the spin direction
    public var ω: Vector3 // the pulsation around the spin spins
    public var name: String // the name of this atom
    public var type: Int // the type of this atom

    public init(spin: Vector3, ω: Vector3? = Vector3(), name: String, type: Int? = 0){
        self.spin=spin
        self.ω=ω!
        self.name=name
        self.type=type!
    }

    convenience init(){
        self.init(spin: Vector3(), ω: Vector3(), name: "Unnamed", type: 0)
    }

    public func advance(method: String, Δt: Double){
        var s = Vector3()
        switch method.lowercased() {
        case "euler" :
            s = spin + Δt * (ω × spin)
        case "symplectic" :
            let ω2 = (ω°ω)
            let c = (0.25*Δt*Δt)
            let c2 = 1.0/((1.0 + c*ω2))
            var s1 = Vector3()
            s1 = c*((2.0*(ω°spin))*ω - ω2*spin)
            s1 += Δt * (ω × spin)
            s = c2 * (spin + s1)
        default: break
        }
        spin = s
        spin.Normalize()
    }

    public func Print(){
      print("ω=<\(ω.x),\(ω.y),\(ω.z)>")
      print("s=<\(spin.x),\(spin.y),\(spin.z)>")
    }

    public func write(url: String){
#if os(Linux)
    let fileName = url.lastPathComponent
    let fileType = fileName.pathExtension
#endif
#if os(macOS)
	let fileName = (url as NSString).lastPathComponent
    let fileType = (fileName as NSString).pathExtension
#endif
    switch fileType.lowercased() {
        case "xyz":
        print(fileName)
        case "json":
        print(fileName)
        case "dat":
        print(fileName)
        default : break
        }
    }
}   
