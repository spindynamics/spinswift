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
infix operator ⊗

public class Vector3: Codable {
    var x, y, z: Double

    public init(
        x: Double? = 0, y: Double? = 0, z: Double? = 0, direction: String? = nil,
        normalize: Bool? = false
    ) {
        self.x = x!
        self.y = y!
        self.z = z!
        switch normalize {
        case true?: self.normalized()
        default: break
        }
        switch direction?.lowercased() {
        case "+x"?:
            self.x = 1
            self.y = 0
            self.z = 0
        case "-x"?:
            self.x = -1
            self.y = 0
            self.z = 0
        case "+y"?:
            self.x = 0
            self.y = 1
            self.z = 0
        case "-y"?:
            self.x = 0
            self.y = -1
            self.z = 0
        case "+z"?:
            self.x = 0
            self.y = 0
            self.z = 1
        case "-z"?:
            self.x = 0
            self.y = 0
            self.z = -1
        case "random"?:
            self.x = Double.random(in: -1...1)
            self.y = Double.random(in: -1...1)
            self.z = Double.random(in: -1...1)
            self.normalized()
        default: break
        }
    }

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    static var zero: Vector3 = Vector3(x: 0, y: 0, z: 0)

    // Compute the norm of a 3D vector
    func norm() -> Double {
        return ((x * x) + (y * y) + (z * z)).squareRoot()
    }

    // Normalize all the components of a 3D vector
    func normalized() {
        let norm: Double = self.norm()
        if norm != 0 {
            x /= norm
            y /= norm
            z /= norm
        }
    }

    func print() {
        Swift.print("<\(self.x),\(self.y),\(self.z)>")
    }

    public static func + (a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(x: (a.x) + (b.x), y: (a.y) + (b.y), z: (a.z) + (b.z))
    }

    public static func - (a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(x: (a.x) - (b.x), y: (a.y) - (b.y), z: (a.z) - (b.z))
    }

    public static func += (a: inout Vector3, b: Vector3) {
        a = a + b
    }

    public static func -= (a: inout Vector3, b: Vector3) {
        a = a - b
    }

    /// Compute the cross product of two vectors
    public static func × (a: Vector3, b: Vector3) -> Vector3 {
        return Vector3(
            x: ((a.y) * (b.z)) - ((a.z) * (b.y)), y: ((a.z) * (b.x)) - ((a.x) * (b.z)),
            z: ((a.x) * (b.y)) - ((a.y) * (b.x)))
    }

    /// Compute the dot product between two vectors
    public static func ° (a: Vector3, b: Vector3) -> Double {
        return ((a.x) * (b.x)) + ((a.y) * (b.y)) + ((a.z) * (b.z))
    }

    /// Compute the multiplication of a vector by a scalar number
    public static func * (a: Double, b: Vector3) -> Vector3 {
        return Vector3(x: a * (b.x), y: a * (b.y), z: a * (b.z))
    }

    /// Implementation of Equatable Vector3
    public static func == (a: Vector3, b: Vector3) -> Bool {
        return (a.x == b.x) && (a.y == b.y) && (a.z == b.z)
    }

    /// A function to print data in a json format
    public func jsonify() throws -> String {
=======
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

  /// Compute the outer product between two vector3 
  public static func ⊗ (a: Vector3, b: Vector3) -> Matrix3 {
    let c1: Double = (a.x) * (b.x) 
    let c2: Double = (a.x) * (b.y) 
    let c3: Double = (a.x) * (b.z)
    let c4: Double = (a.y) * (b.x) 
    let c5: Double = (a.y) * (b.y) 
    let c6: Double = (a.y) * (b.z) 
    let c7: Double = (a.z) * (b.x) 
    let c8: Double = (a.z) * (b.y)
    let c9: Double = (a.z) * (b.z)

    return Matrix3(xx: c1, xy: c2, xz: c3, yx: c4, yy: c5, yz: c6, zx: c7, zy: c8, zz: c9)
  }

  /// A function to print data in a json format
  public func jsonify() throws -> String {

        let data: Data = try JSONEncoder().encode(self)
        if let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        } else {
            throw NSError(
                domain: "EncodingError", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON"])
        }
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
          case "test"?: self.xx = 3 ; self.xy = 4 ; self.xz = 5 ; self.yx = 3 ; self.yy = 1 ; self.yz = 6 ; self.zx = 9 ; self.zy = 0 ; self.zz = 0
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

  // Return the diagonal matrix of 3x3 Matrix
  func Diag() -> Matrix3 {
    return Matrix3(xx: self.xx, xy: 0, xz: 0, yx: 0, yy: self.yy, yz: 0, zx: 0, zy: 0, zz: self.zz)
  }

  // compute the transpose of a 3x3 Matrix
  func Transpose() -> Matrix3 {
    let c1: Double = xx
    let c2: Double = yx
    let c3: Double = zx
    let c4: Double = xy
    let c5: Double = yy
    let c6: Double = zy
    let c7: Double = xz
    let c8: Double = yz
    let c9: Double = zz

    return Matrix3(xx: c1, xy: c2, xz: c3, yx: c4, yy: c5, yz: c6, zx: c7, zy: c8, zz: c9)
  }

  // compute the cofactor for a 3x3 Matrix 
  func Cofactor() -> Matrix3 {
    let c1: Double = (yy*zz) - (yz*zy)
    let c2: Double = (yz*zx) - (yx*zz)
    let c3: Double = (yx*zy) - (yy*zx)
    let c4: Double = (xz*zy) - (xy*zz)
    let c5: Double = (xx*zz) - (xz*zx)
    let c6: Double = (xy*zx) - (xx*zy)
    let c7: Double = (xy*yz) - (xz*yy)
    let c8: Double = (xz*yx) - (xx*yz)
    let c9: Double = (xx*yy) - (xy*yx)

    return Matrix3(xx: c1, xy: c2, xz: c3, yx: c4, yy: c5, yz: c6, zx: c7, zy: c8, zz: c9)
  }

  // compute the adjunct for a 3x3 Matrix
  func Adjoint() -> Matrix3 {
   return self.Cofactor().Transpose()  
  }

  // compute the inverse for a 3x3 Matrix
  func Inverse() -> Matrix3 {
   guard self.Det() != 0 else {print("Matrix is not invertible!"); exit(-1)} 
   return (1/self.Det())*self.Adjoint()
  }

  func Print() {
    var s:String = "["
    s.append(String(format:"%5.2f ",self.xx))
    s.append(String(format:"%5.2f ",self.xy))
    s.append(String(format:"%5.2f",self.xz))
    s.append("]")
    s.append("\n")
    s.append("[")
    s.append(String(format:"%5.2f ",self.yx))
    s.append(String(format:"%5.2f ",self.yy))
    s.append(String(format:"%5.2f",self.yz))
    s.append("]")
    s.append("\n")
    s.append("[")
    s.append(String(format:"%5.2f ",self.zx))
    s.append(String(format:"%5.2f ",self.zy))
    s.append(String(format:"%5.2f",self.zz))
    s.append("]")
    print(s)
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
    let c1: Double = ((a.xx) * (b.xx)) + ((a.xy) * (b.yx)) + ((a.xz) * (b.zx))
    let c2: Double = ((a.xx) * (b.xy)) + ((a.xy) * (b.yy)) + ((a.xz) * (b.zy))
    let c3: Double = ((a.xx) * (b.xz)) + ((a.xy) * (b.yz)) + ((a.xz) * (b.zz))
    let c4: Double = ((a.yx) * (b.xx)) + ((a.yy) * (b.yx)) + ((a.yz) * (b.zx))
    let c5: Double = ((a.yx) * (b.xy)) + ((a.yy) * (b.yy)) + ((a.yz) * (b.zy))
    let c6: Double = ((a.yx) * (b.xz)) + ((a.yy) * (b.yz)) + ((a.yz) * (b.zz))
    let c7: Double = ((a.zx) * (b.xx)) + ((a.zy) * (b.yx)) + ((a.zz) * (b.zx))
    let c8: Double = ((a.zx) * (b.xy)) + ((a.zy) * (b.yy)) + ((a.zz) * (b.zy))
    let c9: Double = ((a.zx) * (b.xz)) + ((a.zy) * (b.yz)) + ((a.zz) * (b.zz))
   
    return Matrix3(xx: c1, xy: c2, xz: c3, yx: c4, yy: c5, yz: c6, zx: c7, zy: c8, zz: c9)
  }

  /// Compute the product of a Vector3 and Matrix3
  public static func * (a: Matrix3, b: Vector3) -> Vector3 {
    let c1: Double = ((a.xx) * (b.x)) + ((a.xy) * (b.y)) + ((a.xz) * (b.z))
    let c2: Double = ((a.yx) * (b.x)) + ((a.yy) * (b.y)) + ((a.yz) * (b.z))
    let c3: Double = ((a.zx) * (b.x)) + ((a.zy) * (b.y)) + ((a.zz) * (b.z))
    
    return Vector3(x: c1, y: c2, z: c3)
  }

  /// Compute the cross product between a Matrix 3x3 and a vector 3x1
  public static func × (b: Vector3, a: Matrix3) -> Matrix3 {
    let c1: Double = ((a.zx) * (b.y)) - ((a.yx) * (b.z))
    let c2: Double = ((a.zy) * (b.y)) - ((a.yy) * (b.z))
    let c3: Double = ((a.zz) * (b.y)) - ((a.yz) * (b.z))
    let c4: Double = ((a.xx) * (b.z)) - ((a.zx) * (b.x)) 
    let c5: Double = ((a.xy) * (b.z)) - ((a.zy) * (b.x)) 
    let c6: Double = ((a.xz) * (b.z)) - ((a.zz) * (b.x)) 
    let c7: Double = ((a.yx) * (b.x)) - ((a.xx) * (b.y)) 
    let c8: Double = ((a.yy) * (b.x)) - ((a.yx) * (b.y))
    let c9: Double = ((a.yz) * (b.x)) - ((a.xz) * (b.y))

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
