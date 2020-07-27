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
//  hamiltonian.swift
//  Spinswift
//
//  Created by Pascal Thibaudeau on 24/03/2017.
*/
import Foundation

public class Hamiltonian {

  public var atoms = [Atom]()
  public var geometry = Geometry()

  let ℏ=PhysicalConstants().ℏ.value
  let γ=PrecessionConstants().γ.value

  var Zeeman   = (computed : false, B: Vector3())
  var exchange = (computed : false, J: Double(), n: [[Int]]())
  var dmi      = (computed : false, D: Double(), n: [[Int]]())
  var damping  = (computed : false, alpha: Double())
  var uniaxial = (computed : false, value: Double(), axis: Vector3())

  public init(fromAtoms: [Atom], fromGeometry: Geometry ){
    atoms = fromAtoms
    geometry = fromGeometry 
  }

  public func printProperties(){
    for (index,_) in atoms.enumerated() {
      print("r[\(index)]=<\(geometry.r[index].x),\(geometry.r[index].y),\(geometry.r[index].z)>")
      print("ω[\(index)]=<\(atoms[index].ω.x),\(atoms[index].ω.y),\(atoms[index].ω.z)>")
      print("s[\(index)]=<\(atoms[index].spin.x),\(atoms[index].spin.y),\(atoms[index].spin.z)>")
    }
  }

  public func externalDCField(value: Vector3) {
    let coef = γ*value
    for (index,_) in atoms.enumerated() {
      atoms[index].ω += coef
    }
    Zeeman.computed = true
    Zeeman.B = value
  }

  public func exchangeField (value: Double, n: [[Int]]){
    let coef = (value/ℏ)

    for (index1,_) in atoms.enumerated() {
      for (index2,_) in n[index1].enumerated() {
        atoms[index1].ω += coef*(atoms[index2].spin)
      }
    }
    exchange.computed = true
    exchange.J = value
    exchange.n = n
  }

  public func dmiField (value: Double, n: [[Int]]){
    let coef = (value/ℏ)
    for (index1,_) in atoms.enumerated() {
      for (index2,_) in n[index1].enumerated() {
        let d=geometry.Distance(atom1:index1, atom2: index2)
        let rij = (1.0/d)*(geometry.r[index1] - geometry.r[index2])
        atoms[index1].ω += coef*(rij × (atoms[index2].spin))
      }
    }
    dmi.computed = true
    dmi.D = value
    dmi.n = n
  }

  public func damping (value: Double){
    let coef = 1.0/(1.0+value*value)
    for (index,_) in atoms.enumerated() {
      let a = atoms[index].ω
      atoms[index].ω = coef*(a - value*(a × (atoms[index].spin) ))
    }
    damping.computed = true
    damping.alpha = value
  }
  
  public func uniaxialAnisotropyField (value: Double, axis: Vector3) {
    for (index,_) in atoms.enumerated() {
      let coef = -(value/ℏ)*(axis°(atoms[index].spin))
      atoms[index].ω += coef*axis
    }
    uniaxial.computed = true
    uniaxial.value = value
    uniaxial.axis = axis
  }

  public func cubicAnisotropyField () {
  }
  
  public func spinTransfertTorqueField (){
  }

  public func temperatureField (){
  }

  public func energy (){
  }

  public func evolve (stop: Double, timestep: Double, method: String? = nil, file: String){
    switch method?.lowercased(){
      case "euler"? :
      self.evolveEuler(stop: stop, timestep: timestep, fileName: file)
      case "symplectic"? :
      self.evolveSymplectic(stop: stop, timestep: timestep, fileName: file)
      default: break
    }
  }

  public func evolveEuler (stop: Double, timestep: Double, fileName: String){
    var currentTime: Double = 0.0
    var content=String()

    while (currentTime < stop) {
      for a in atoms {
        content += String(currentTime)+" "+String(a.spin.x)+" "+String(a.spin.y)+" "+String(a.spin.z)+"\n"
        a.advance(method: "euler", Δt: timestep)
      }
      self.update()
      currentTime+=timestep
    }
    //let home = FileManager.default.homeDirectoryForCurrentUser
    saveOnFile(data:content, fileName: fileName)
  }

  public func evolveSymplectic (stop: Double, timestep: Double, fileName: String){
    var currentTime: Double = 0.0
    var content=String()

    while (currentTime < stop) {
      for a in atoms {
        content += String(currentTime)+" "+String(a.spin.x)+" "+String(a.spin.y)+" "+String(a.spin.z)+"\n"
        a.advance(method: "symplectic", Δt: timestep)
      }
      self.update()
      currentTime+=timestep
    }
    
    saveOnFile(data:content, fileName: fileName)
  }

  func update(){
    for a in atoms {a.ω=Vector3()} //erase the effective fields
    
    if (Zeeman.computed) {self.externalDCField(value: Zeeman.B)}
    if (uniaxial.computed) {self.uniaxialAnisotropyField(value: uniaxial.value, axis: uniaxial.axis)}
    if (exchange.computed) {self.exchangeField(value: exchange.J, n: exchange.n)}
    if (dmi.computed) {self.dmiField(value: dmi.D, n: dmi.n)}
    if (damping.computed) {self.damping(value: damping.alpha)}
  }
}
