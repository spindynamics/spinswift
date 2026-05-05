import Foundation

/// A struct representing a 3x3 matrix with value semantics.
///
/// This struct provides a comprehensive set of operations for 3x3 matrices, including
/// arithmetic, linear algebra properties (trace, determinant, inverse), and specialized
/// transformations used in spin dynamics simulations.
///
/// - Author: Mouad Fattouhi
/// - Date: 26/07/2024
/// - Version: 0.3 (SIMD3 Row-Based)
infix operator **

public struct Matrix3: Codable, Sendable {
  /// Internal SIMD3 row storage for hardware acceleration.
  private var row0: SIMD3<Double>
  private var row1: SIMD3<Double>
  private var row2: SIMD3<Double>

  /// Backward-compatible computed properties for matrix components.
  @inline(__always) public var xx: Double {
    get { row0[0] }
    set { row0[0] = newValue }
  }
  @inline(__always) public var xy: Double {
    get { row0[1] }
    set { row0[1] = newValue }
  }
  @inline(__always) public var xz: Double {
    get { row0[2] }
    set { row0[2] = newValue }
  }
  @inline(__always) public var yx: Double {
    get { row1[0] }
    set { row1[0] = newValue }
  }
  @inline(__always) public var yy: Double {
    get { row1[1] }
    set { row1[1] = newValue }
  }
  @inline(__always) public var yz: Double {
    get { row1[2] }
    set { row1[2] = newValue }
  }
  @inline(__always) public var zx: Double {
    get { row2[0] }
    set { row2[0] = newValue }
  }
  @inline(__always) public var zy: Double {
    get { row2[1] }
    set { row2[1] = newValue }
  }
  @inline(__always) public var zz: Double {
    get { row2[2] }
    set { row2[2] = newValue }
  }

  /// Initializes a 3x3 matrix with optional components or a predefined fill pattern.
  public init(
    xx: Double? = 0, xy: Double? = 0, xz: Double? = 0, yx: Double? = 0, yy: Double? = 0,
    yz: Double? = 0, zx: Double? = 0, zy: Double? = 0, zz: Double? = 0, fill: String? = nil
  ) {
    self.row0 = SIMD3<Double>(xx ?? 0, xy ?? 0, xz ?? 0)
    self.row1 = SIMD3<Double>(yx ?? 0, yy ?? 0, yz ?? 0)
    self.row2 = SIMD3<Double>(zx ?? 0, zy ?? 0, zz ?? 0)

    if let fillPattern = fill?.lowercased() {
      switch fillPattern {
      case "zeros":
        setAll(0)
      case "ones":
        setAll(1)
      case "test":
        row0 = SIMD3(3, 4, 5)
        row1 = SIMD3(3, 1, 6)
        row2 = SIMD3(9, 0, 0)
      case "identity":
        row0 = SIMD3(1, 0, 0)
        row1 = SIMD3(0, 1, 0)
        row2 = SIMD3(0, 0, 1)
      case "antisym":
        row0 = SIMD3(0, 1, 1)
        row1 = SIMD3(-1, 0, 1)
        row2 = SIMD3(-1, -1, 0)
      case "random":
        row0 = SIMD3(
          Double.random(in: -1...1), Double.random(in: -1...1), Double.random(in: -1...1))
        row1 = SIMD3(
          Double.random(in: -1...1), Double.random(in: -1...1), Double.random(in: -1...1))
        row2 = SIMD3(
          Double.random(in: -1...1), Double.random(in: -1...1), Double.random(in: -1...1))
      default: break
      }
    }
  }

  /// Initializes a 3x3 matrix with all nine components explicitly.
  @inline(__always)
  public init(
    _ xx: Double, _ xy: Double, _ xz: Double, _ yx: Double, _ yy: Double, _ yz: Double,
    _ zx: Double, _ zy: Double, _ zz: Double
  ) {
    self.row0 = SIMD3<Double>(xx, xy, xz)
    self.row1 = SIMD3<Double>(yx, yy, yz)
    self.row2 = SIMD3<Double>(zx, zy, zz)
  }

  /// Internal initializer for SIMD row storage.
  @inline(__always)
  internal init(row0: SIMD3<Double>, row1: SIMD3<Double>, row2: SIMD3<Double>) {
    self.row0 = row0
    self.row1 = row1
    self.row2 = row2
  }

  @inline(__always)
  private mutating func setAll(_ val: Double) {
    let v = SIMD3<Double>(repeating: val)
    row0 = v
    row1 = v
    row2 = v
  }

  /// Internal SIMD3 cross product helper.
  @inline(__always)
  private static func cross(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> SIMD3<Double> {
    SIMD3(
      a.y * b.z - a.z * b.y,
      a.z * b.x - a.x * b.z,
      a.x * b.y - a.y * b.x
    )
  }

  /// Computes the trace of the matrix (sum of diagonal elements).
  @inline(__always)
  public func Trace() -> Double {
    return row0[0] + row1[1] + row2[2]
  }

  /// Computes the determinant of the 3x3 matrix using the triple scalar product.
  @inline(__always)
  public func Determinant() -> Double {
    let c = Self.cross(row1, row2)
    return (row0 * c).sum()
  }

  /// Returns a new matrix containing only the diagonal elements of the current matrix.
  @inline(__always)
  public func Diagonal() -> Matrix3 {
    return Matrix3(
      row0: SIMD3(row0[0], 0, 0),
      row1: SIMD3(0, row1[1], 0),
      row2: SIMD3(0, 0, row2[2])
    )
  }

  /// Computes the transpose of a 3x3 matrix.
  @inline(__always)
  public func Transpose() -> Matrix3 {
    return Matrix3(
      row0: SIMD3(row0[0], row1[0], row2[0]),
      row1: SIMD3(row0[1], row1[1], row2[1]),
      row2: SIMD3(row0[2], row1[2], row2[2])
    )
  }

  /// Computes the cofactor matrix of a 3x3 matrix using SIMD cross products.
  @inline(__always)
  public func Cofactor() -> Matrix3 {
    return Matrix3(
      row0: Self.cross(row1, row2), row1: Self.cross(row2, row0), row2: Self.cross(row0, row1))
  }

  /// Computes the adjoint matrix of a 3x3 matrix.
  @inline(__always)
  public func Adjoint() -> Matrix3 {
    return self.Cofactor().Transpose()
  }

  /// Computes the inverse of the 3x3 matrix.
  @inline(__always)
  public func Inverse() -> Matrix3 {
    let det = self.Determinant()
    guard det != 0 else {
      print("Matrix is not invertible!")
      exit(-1)
    }
    return (1.0 / det) * self.Adjoint()
  }

  /// Displays the matrix in a formatted string.
  public func Displayed(precision: Int = 2, alignment: String = "right", separator: String = " ") {
    let formatString =
      "%"
      + (alignment == "right" ? "" : "-")
      + "\(precision + 3).\(precision)f"

    let row1Str = String(
      format: "[\(formatString)\(separator)\(formatString)\(separator)\(formatString)]",
      row0[0], row0[1], row0[2])
    let row2Str = String(
      format: "[\(formatString)\(separator)\(formatString)\(separator)\(formatString)]",
      row1[0], row1[1], row1[2])
    let row3Str = String(
      format: "[\(formatString)\(separator)\(formatString)\(separator)\(formatString)]",
      row2[0], row2[1], row2[2])

    print(row1Str)
    print(row2Str)
    print(row3Str)
  }

  // MARK: - Codable

  private enum CodingKeys: String, CodingKey {
    case xx, xy, xz, yx, yy, yz, zx, zy, zz
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let xx = try container.decode(Double.self, forKey: .xx)
    let xy = try container.decode(Double.self, forKey: .xy)
    let xz = try container.decode(Double.self, forKey: .xz)
    let yx = try container.decode(Double.self, forKey: .yx)
    let yy = try container.decode(Double.self, forKey: .yy)
    let yz = try container.decode(Double.self, forKey: .yz)
    let zx = try container.decode(Double.self, forKey: .zx)
    let zy = try container.decode(Double.self, forKey: .zy)
    let zz = try container.decode(Double.self, forKey: .zz)
    self.row0 = SIMD3<Double>(xx, xy, xz)
    self.row1 = SIMD3<Double>(yx, yy, yz)
    self.row2 = SIMD3<Double>(zx, zy, zz)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(row0[0], forKey: .xx)
    try container.encode(row0[1], forKey: .xy)
    try container.encode(row0[2], forKey: .xz)
    try container.encode(row1[0], forKey: .yx)
    try container.encode(row1[1], forKey: .yy)
    try container.encode(row1[2], forKey: .yz)
    try container.encode(row2[0], forKey: .zx)
    try container.encode(row2[1], forKey: .zy)
    try container.encode(row2[2], forKey: .zz)
  }

  // MARK: - Arithmetic Operators

  @inline(__always)
  public static func + (a: Matrix3, b: Matrix3) -> Matrix3 {
    return Matrix3(row0: a.row0 + b.row0, row1: a.row1 + b.row1, row2: a.row2 + b.row2)
  }

  @inline(__always)
  public static func - (a: Matrix3, b: Matrix3) -> Matrix3 {
    return Matrix3(row0: a.row0 - b.row0, row1: a.row1 - b.row1, row2: a.row2 - b.row2)
  }

  @inline(__always)
  public static func += (a: inout Matrix3, b: Matrix3) {
    a.row0 += b.row0
    a.row1 += b.row1
    a.row2 += b.row2
  }

  @inline(__always)
  public static func -= (a: inout Matrix3, b: Matrix3) {
    a.row0 -= b.row0
    a.row1 -= b.row1
    a.row2 -= b.row2
  }

  /// Compute the product of two matrices using SIMD dot products.
  public static func * (a: Matrix3, b: Matrix3) -> Matrix3 {
    let bCol0 = SIMD3(b.row0[0], b.row1[0], b.row2[0])
    let bCol1 = SIMD3(b.row0[1], b.row1[1], b.row2[1])
    let bCol2 = SIMD3(b.row0[2], b.row1[2], b.row2[2])

    return Matrix3(
      row0: SIMD3((a.row0 * bCol0).sum(), (a.row0 * bCol1).sum(), (a.row0 * bCol2).sum()),
      row1: SIMD3((a.row1 * bCol0).sum(), (a.row1 * bCol1).sum(), (a.row1 * bCol2).sum()),
      row2: SIMD3((a.row2 * bCol0).sum(), (a.row2 * bCol1).sum(), (a.row2 * bCol2).sum())
    )
  }

  /// Compute the product of a Matrix3 and Vector3 using SIMD dot products.
  @inline(__always)
  public static func * (a: Matrix3, b: Vector3) -> Vector3 {
    let s = b.simd
    return Vector3((a.row0 * s).sum(), (a.row1 * s).sum(), (a.row2 * s).sum())
  }

  /// Compute the cross product between a vector and a matrix.
  @inline(__always)
  public static func × (b: Vector3, a: Matrix3) -> Matrix3 {
    let v = b.simd
    return Matrix3(
      row0: Self.cross(v, a.row0), row1: Self.cross(v, a.row1), row2: Self.cross(v, a.row2))
  }

  /// Compute the multiplication of a scalar with a Matrix3.
  @inline(__always)
  public static func * (a: Double, b: Matrix3) -> Matrix3 {
    return Matrix3(row0: a * b.row0, row1: a * b.row1, row2: a * b.row2)
  }

  /// Computes the power of a Matrix3 using exponentiation by squaring.
  public static func ** (a: Matrix3, b: Int) -> Matrix3 {
    guard b >= 0 else {
      print("Exponent must be non-negative. Returning identity matrix.")
      return Matrix3(fill: "identity")
    }

    var result = Matrix3(fill: "identity")
    var base = a
    var exponent = b

    while exponent > 0 {
      if exponent % 2 == 1 {
        result = result * base
      }
      base = base * base
      exponent /= 2
    }

    return result
  }

  /// Comparing two matrices.
  @inline(__always)
  public static func == (a: Matrix3, b: Matrix3) -> Bool {
    return (a.row0 == b.row0) && (a.row1 == b.row1) && (a.row2 == b.row2)
  }

  /// Serializes the matrix into a JSON string.
  public func jsonify() throws -> String {
    let data = try JSONEncoder().encode(self)
    if let jsonString = String(data: data, encoding: .utf8) {
      return jsonString
    } else {
      throw SpinswiftError.encodingError("Failed to encode JSON")
    }
  }
}
