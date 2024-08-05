/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation
/// A class for managing 3D-vectors
/// 
/// The purpose of this class is to interact with tridimensional vectors. 
/// - Author: Pascal Thibaudeau
/// - Date: 14/04/2023
/// - Version: 0.1
//infix operator + : AdditionPrecedence
infix operator ×
infix operator °
infix operator ^ 

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

  public init(_ x: Double, _ y: Double, _ z: Double) {
    self.x = x
    self.y = y
    self.z = z
  }
  
  // Compute the norm of a 3D vector
  func Norm() -> Double {
    return ((x*x) + (y*y) + (z*z)).squareRoot()
  }

  // Normalize all the components of a 3D vector
  func Normalize() {
      let norm: Double = self.Norm()
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

  /// Compute the cross product of two vectors
  public static func × (a: Vector3, b: Vector3) -> Vector3 {
      return Vector3(x: ((a.y) * (b.z)) - ((a.z) * (b.y)), y: ((a.z) * (b.x)) - ((a.x) * (b.z)), z: ((a.x) * (b.y)) - ((a.y) * (b.x)))
  }

  /// Compute the dot product between two vectors
  public static func ° (a: Vector3, b: Vector3) -> Double {
    return ((a.x) * (b.x)) + ((a.y) * (b.y)) + ((a.z) * (b.z))
  }

  /// Compute the multiplication of a vector by a scalar number
  public static func * (a: Double, b: Vector3) -> Vector3 {
    return Vector3(x: a*(b.x), y: a*(b.y), z: a*(b.z))
  }

  /// Implementation of Equatable Vector3
  public static func == (a: Vector3, b: Vector3) -> Bool {
    return (a.x == b.x) && (a.y == b.y) && (a.z == b.z)
  }

  /// A function to print data in a json format
  public func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}

/// Compute the Euclidean distance between two 3D vectors
  func Distance(_ a: Vector3, _ b: Vector3) -> Double {
    return ((a-b)°(a-b)).squareRoot()
  }


/// A class for managing 3 by 3 Matrices
/// 
/// The purpose of this class is to interact with 3 by 3 Matrices. 
/// - Author: Mouad Fattouhi
/// - Date: 26/07/2024
/// - Version: 0.1

public class Matrix3 : Codable {
  var xx,xy,xz,yx,yy,yz,zx,zy,zz: Double

  public init(xx: Double? = 0 , xy: Double? = 0, xz: Double? = 0, yx: Double? = 0 , yy: Double? = 0, yz: Double? = 0, zx: Double? = 0 , zy: Double? = 0, zz: Double? = 0, fill: String? = nil) {
       self.xx=xx!
       self.xy=xy!
       self.xz=xz!
       self.yx=yx!
       self.yy=yy!
       self.yz=yz!
       self.zx=zx!
       self.zy=zy!
       self.zz=zz!

       switch fill?.lowercased() {
          case "zeros"?: self.xx = 0 ; self.xy = 0 ; self.xz = 0 ; self.yx = 0 ; self.yy = 0 ; self.yz = 0 ; self.zx = 0 ; self.zy = 0 ; self.zz = 0
          case "ones"?: self.xx = 1 ; self.xy = 1 ; self.xz = 1 ; self.yx = 1 ; self.yy = 1 ; self.yz = 1 ; self.zx = 1 ; self.zy = 1 ; self.zz = 1
          case "identity"?: self.xx = 1 ; self.xy = 0 ; self.xz = 0 ; self.yx = 0 ; self.yy = 1 ; self.yz = 0 ; self.zx = 0 ; self.zy = 0 ; self.zz = 1
          case "antisym"?: self.xx = 0 ; self.xy = 1 ; self.xz = 1 ; self.yx = -1 ; self.yy = 0 ; self.yz = 1 ; self.zx = -1 ; self.zy = -1 ; self.zz = 0
          case "random"?:
          self.xx=Double.random(in: -1...1)
          self.xy=Double.random(in: -1...1)
          self.xz=Double.random(in: -1...1)
          self.yx=Double.random(in: -1...1)
          self.yy=Double.random(in: -1...1)
          self.yz=Double.random(in: -1...1)
          self.zx=Double.random(in: -1...1)
          self.zy=Double.random(in: -1...1)
          self.xz=Double.random(in: -1...1)
        default: break
    } 
  }

  public init(_ xx: Double, _ xy: Double, _ xz: Double, _ yx: Double, _ yy: Double, _ yz: Double, _ zx: Double, _ zy: Double, _ zz: Double) {
    self.xx = xx
    self.xy = xy
    self.xz = xz
    self.yx = yx
    self.yy = yy
    self.yz = yz
    self.zx = zx
    self.zy = zy
    self.zz = zz
  }
  
  // Compute the Trace of a 3x3 Matrix
  func Trace() -> Double {
    return xx + yy + zz
  }

  // Compute determinant of a 3x3 Matrix
  func Det() -> Double {
    return xx*(yy*zz-yz*zy)-xy*(yx*zz-yz*zx)+xz*(yx*zy-yy*zx)
  }

  // compute the transpose of a 3x3 Matrix
  func Transpose() -> Matrix3 {
    var c1,c2,c3,c4,c5,c6,c7,c8,c9: Double
    c1=xx
    c2=yx
    c3=zx
    c4=xy
    c5=yy
    c6=zy
    c7=xz
    c8=yz
    c9=zz

    return Matrix3(xx: c1, xy: c2, xz: c3, yx: c4, yy: c5, yz: c6, zx: c7, zy: c8, zz: c9)
  }

  // compute the cofactor for a 3x3 Matrix 
  func Cofactor() -> Matrix3 {
    var c1,c2,c3,c4,c5,c6,c7,c8,c9: Double
    c1 = (yy*zz) - (yz*zy)
    c2 = (yz*zx) - (yx*zz)
    c3 = (yx*zy) - (yy*zx)
    c4 = (xz*zy) - (xy*zz)
    c5 = (xx*zz) - (xz*zx)
    c6 = (xy*zx) - (xx*zy)
    c7 = (xy*yz) - (xz*yy)
    c8 = (xz*yx) - (xx*yz)
    c9 = (xx*yy) - (xy*yx)

    return Matrix3(xx: c1, xy: c2, xz: c3, yx: c4, yy: c5, yz: c6, zx: c7, zy: c8, zz: c9)
  }

  // compute the adjunct for a 3x3 Matrix
  func Adjoint() -> Matrix3{
   let Cof: Matrix3 = self.Cofactor()

   return Cof.Transpose()  
  }

  // compute the inverse for a 3x3 Matrix
  func Inverse() -> Matrix3{
   let Adj: Matrix3 = self.Adjoint()
   let Deta: Double = self.Det()
   if (Deta == 0) {print(GeneralSettings.WriteCol.red+"This is a singular Matrix: No invese is found"+GeneralSettings.WriteCol.reset)
   return  Matrix3(fill:"zeros")}
   else {return  (1/Deta)*Adj} 
  }

  func Print() {
    print("[\(self.xx),\(self.xy),\(self.xz) \n\(self.yx),\(self.yy),\(self.yz) \n\(self.zx),\(self.zy),\(self.zz)]")
  }

  public static func + (a: Matrix3, b: Matrix3) -> Matrix3 {
    return Matrix3(xx: (a.xx)+(b.xx), xy: (a.xy)+(b.xy), xz:(a.xz)+(b.xz), yx: (a.yx)+(b.yx), yy: (a.yy)+(b.yy), yz:(a.yz)+(b.yz), zx: (a.zx)+(b.zx), zy: (a.zy)+(b.zy), zz:(a.zz)+(b.zz))
  }

  public static func - (a: Matrix3, b: Matrix3) -> Matrix3 {
    return Matrix3(xx: (a.xx)-(b.xx), xy: (a.xy)-(b.xy), xz:(a.xz)-(b.xz), yx: (a.yx)-(b.yx), yy: (a.yy)-(b.yy), yz:(a.yz)-(b.yz), zx: (a.zx)-(b.zx), zy: (a.zy)-(b.zy), zz:(a.zz)-(b.zz))
  }

  public static func += (a: inout Matrix3, b: Matrix3) {
    var c: Matrix3 = Matrix3()
    c = a + b
    a = c
  }

  public static func -= (a: inout Matrix3, b: Matrix3) {
    var c: Matrix3 = Matrix3()
    c = a - b
    a = c
  }

  /// Compute the product of two Matrices
  public static func * (a: Matrix3, b: Matrix3) -> Matrix3 {
    var c1,c2,c3,c4,c5,c6,c7,c8,c9: Double
    c1 = ((a.xx) * (b.xx)) + ((a.xy) * (b.yx)) + ((a.xz) * (b.zx))
    c2 = ((a.xx) * (b.xy)) + ((a.xy) * (b.yy)) + ((a.xz) * (b.zy))
    c3 = ((a.xx) * (b.xz)) + ((a.xy) * (b.yz)) + ((a.xz) * (b.zz))
    c4 = ((a.yx) * (b.xx)) + ((a.yy) * (b.yx)) + ((a.yz) * (b.zx))
    c5 = ((a.yx) * (b.xy)) + ((a.yy) * (b.yy)) + ((a.yz) * (b.zy))
    c6 = ((a.yx) * (b.xz)) + ((a.yy) * (b.yz)) + ((a.yz) * (b.zz))
    c7 = ((a.zx) * (b.xx)) + ((a.zy) * (b.yx)) + ((a.zz) * (b.zx))
    c8 = ((a.zx) * (b.xy)) + ((a.zy) * (b.yy)) + ((a.zz) * (b.zy))
    c9 = ((a.zx) * (b.xz)) + ((a.zy) * (b.yz)) + ((a.zz) * (b.zz))
   
    return Matrix3(xx: c1, xy: c2, xz: c3, yx: c4, yy: c5, yz: c6, zx: c7, zy: c8, zz: c9)
  }

  /// Compute the cross product between a Matrix 3x3 and a vector 3x1
  public static func × (a: Matrix3, b: Vector3) -> Matrix3 {
    var c1,c2,c3,c4,c5,c6,c7,c8,c9: Double
    c1 = ((a.zx) * (b.y)) - ((a.yx) * (b.z))
    c2 = ((a.zy) * (b.y)) - ((a.yy) * (b.z))
    c3 = ((a.zz) * (b.y)) - ((a.yz) * (b.z))
    c4 = ((a.xx) * (b.z)) - ((a.zx) * (b.x)) 
    c5 = ((a.xy) * (b.z)) - ((a.zy) * (b.x)) 
    c6 = ((a.xz) * (b.z)) - ((a.zz) * (b.x)) 
    c7 = ((a.yx) * (b.x)) - ((a.xx) * (b.y)) 
    c8 = ((a.yy) * (b.x)) - ((a.yx) * (b.y))
    c9 = ((a.yz) * (b.x)) - ((a.xz) * (b.y))

    return Matrix3(xx: c1, xy: c2, xz: c3, yx: c4, yy: c5, yz: c6, zx: c7, zy: c8, zz: c9)
  }

  /// Compute the multiplication of a scalar with a Matrix 3x3
  public static func * (a: Double, b: Matrix3) -> Matrix3 {
    return Matrix3(xx: a*(b.xx), xy: a*(b.xy), xz: a*(b.xz), yx: a*(b.yx), yy: a*(b.yy), yz: a*(b.yz), zx: a*(b.zx), zy: a*(b.zy), zz: a*(b.zz))
  }

  ///Compute the power of a Matrix 3x3
  public static func ^ (a: Matrix3, b: Int) -> Matrix3 {
    var i: Int = 1
    var d: Matrix3 = a
    while i<b {
      d=d*a
      i+=1
    }
   return d
  }
 
  /// Comparing two matrices
  public static func == (a: Matrix3, b: Matrix3) -> Bool {
    return (a.xx == b.xx) && (a.xy == b.xy) && (a.xz == b.xz) && (a.yx == b.yx) && (a.yy == b.yy) && (a.yz == b.yz) && (a.zx == b.zx) && (a.zy == b.zy) && (a.zz == b.zz)  
  }

  /// A function to print data in a json format
  public func jsonify() throws -> String {
        let data: Data = try JSONEncoder().encode(self)
        let jsonString: String? = String(data:data, encoding:.utf8) 
        return jsonString!
    } 
}


