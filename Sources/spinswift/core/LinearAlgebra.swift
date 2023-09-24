/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this licen
se, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 9
4042, USA.
*/
import Foundation

infix operator + : AdditionPrecedence
infix operator ×
infix operator °

public class Vector3 : Codable {
  var x,y,z: Double

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
    var c: Vector3 = Vector3()
    c = a + b
    a = c
  }

  public static func -= (a: inout Vector3, b: Vector3) {
    var c: Vector3 = Vector3()
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

  public func jsonify() throws -> String {
        let data = try JSONEncoder().encode(self)
        let jsonString = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}
