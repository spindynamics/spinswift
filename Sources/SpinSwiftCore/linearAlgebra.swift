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

infix operator + : AdditionPrecedence
infix operator ×
infix operator °

public class Vector3 {
  var x: Double = 0
  var y: Double = 0
  var z: Double = 0

  public init(x: Double? = 0 , y: Double? = 0, z: Double? = 0, direction: String? = nil, normalize: Bool? = false) {
      self.x=x!
      self.y=y!
      self.z=z!
      switch normalize {
         case true?: self.Normalize()
         default: break}
      switch direction?.lowercased() {
        case "+x"?: self.x = 1 ; self.y = 0 ; self.z = 0
        case "-x"?: self.x = -1 ; self.y = 0 ; self.z = 0
        case "+y"?: self.x = 0 ; self.y = 1 ; self.z = 0
        case "-y"?: self.x = 0 ; self.y = -1 ; self.z = 0
        case "+z"?: self.x = 0 ; self.y = 0 ; self.z = 1
        case "-z"?: self.x = 0 ; self.y = 0 ; self.z = -1
        case "random"?:
        self.x=Double.random(in: -1...1)
        self.y=Double.random(in: -1...1)
        self.z=Double.random(in: -1...1)
        self.Normalize()
        default: break
    } 
  }

  public init(_ x: Double, _ y: Double, _ z: Double){
    self.x = x
    self.y = y
    self.z = z
  }

  func Norm() -> Double {
    return ((x*x) + (y*y) + (z*z)).squareRoot()
  }

  func Normalize() {
      let norm = self.Norm()
      if norm != 0 {
      x/=norm
      y/=norm
      z/=norm
      }
  }

  func Print() {
    print("<\(self.x),\(self.y),\(self.z)>")
  }

  public static func + (a: Vector3, b: Vector3) -> Vector3 {
    return Vector3(x: (a.x)+(b.x), y: (a.y)+(b.y), z:(a.z)+(b.z))
  }

  public static func - (a: Vector3, b: Vector3) -> Vector3 {
    return Vector3(x: (a.x)-(b.x), y: (a.y)-(b.y), z:(a.z)-(b.z))
  }

  public static func += (a: inout Vector3, b: Vector3) {
    var c = Vector3()
    c = a + b
    a = c
  }

  public static func -= (a: inout Vector3, b: Vector3) {
    var c = Vector3()
    c = a - b
    a = c
  }

  public static func × (a: Vector3, b: Vector3) -> Vector3 {
      return Vector3(x: ((a.y) * (b.z)) - ((a.z) * (b.y)), y: ((a.z) * (b.x)) - ((a.x) * (b.z)), z: ((a.x) * (b.y)) - ((a.y) * (b.x)))
  }

  public static func ° (a: Vector3, b: Vector3) -> Double {
    return ((a.x) * (b.x)) + ((a.y) * (b.y)) + ((a.z) * (b.z))
  }

  public static func * (a: Double, b: Vector3) -> Vector3 {
    return Vector3(x: a*(b.x), y: a*(b.y), z: a*(b.z))
  }
}
