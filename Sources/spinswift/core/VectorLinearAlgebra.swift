/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// A struct for managing 3D-vectors with SIMD acceleration.
///
/// The purpose of this struct is to interact with three-dimensional vectors efficiently
/// using hardware-accelerated SIMD instructions.
/// - Author: Pascal Thibaudeau
/// - Date: 14/04/2023
/// - Version: 0.2 (Optimized)
infix operator ×
infix operator °
infix operator ⊗

public struct Vector3: Codable, Sendable {
  /// Internal SIMD storage for hardware acceleration.
  internal var storage: SIMD3<Double>

  /// The x-component of the vector.
  public var x: Double {
    @inline(__always) get { storage.x }
    @inline(__always) set { storage.x = newValue }
  }

  /// The y-component of the vector.
  public var y: Double {
    @inline(__always) get { storage.y }
    @inline(__always) set { storage.y = newValue }
  }

  /// The z-component of the vector.
  public var z: Double {
    @inline(__always) get { storage.z }
    @inline(__always) set { storage.z = newValue }
  }

  /// Internal accessor for SIMD storage (used by Matrix3).
  @inline(__always)
  var simd: SIMD3<Double> {
    storage
  }

  /// Initializes a new 3D vector with components.
  ///
  /// - Parameters:
  ///   - x: The x-component of the vector.
  ///   - y: The y-component of the vector.
  ///   - z: The z-component of the vector.
  @inline(__always)
  public init(_ x: Double = 0, _ y: Double = 0, _ z: Double = 0) {
    self.storage = SIMD3<Double>(x, y, z)
  }

  /// Internal initializer for SIMD storage.
  @inline(__always)
  internal init(storage: SIMD3<Double>) {
    self.storage = storage
  }

  /// Internal initializer for SIMD storage (private alias for initialization).
  @inline(__always)
  private init(_storage: SIMD3<Double>) {
    self.storage = _storage
  }

  /// Initializes a new 3D vector with optional parameters and direction support.
  ///
  /// - Parameters:
  ///   - x: The x-component of the vector (default is 0).
  ///   - y: The y-component of the vector (default is 0).
  ///   - z: The z-component of the vector (default is 0).
  ///   - direction: An optional string to set predefined directions ("+x", "-x", "+y", etc., or "random").
  ///   - normalize: A boolean indicating whether to normalize the vector after initialization (default is false).
  public init(
    x: Double? = 0, y: Double? = 0, z: Double? = 0, direction: String? = nil,
    normalize: Bool? = false
  ) {
    self.storage = SIMD3<Double>(x ?? 0, y ?? 0, z ?? 0)

    if let dir = direction?.lowercased() {
      switch dir {
      case "+x": self.storage = SIMD3<Double>(1, 0, 0)
      case "-x": self.storage = SIMD3<Double>(-1, 0, 0)
      case "+y": self.storage = SIMD3<Double>(0, 1, 0)
      case "-y": self.storage = SIMD3<Double>(0, -1, 0)
      case "+z": self.storage = SIMD3<Double>(0, 0, 1)
      case "-z": self.storage = SIMD3<Double>(0, 0, -1)
      case "random":
        self.storage = SIMD3<Double>(
          Double.random(in: -1...1),
          Double.random(in: -1...1),
          Double.random(in: -1...1)
        )
        self.normalized()
      default: break
      }
    }

    if normalize == true {
      self.normalized()
    }
  }

  /// Computes the Euclidean norm (magnitude) of the vector.
  ///
  /// - Returns: The norm of the vector.
  @inline(__always)
  func norm() -> Double {
    return (storage * storage).sum().squareRoot()
  }

  /// Normalizes the vector in place.
  ///
  /// If the norm of the vector is zero, the vector remains unchanged.
  mutating func normalized() {
    let n = self.norm()
    if n != 0 {
      storage /= n
    }
  }

  /// Prints the vector components to the console in the format `<x,y,z>`.
  func displayed() {
    Swift.print("<\(self.x),\(self.y),\(self.z)>")
  }

  /// Computes the sum of two vectors.
  @inline(__always)
  public static func + (a: Vector3, b: Vector3) -> Vector3 {
    return Vector3(storage: a.storage + b.storage)
  }

  /// Computes the difference between two vectors.
  @inline(__always)
  public static func - (a: Vector3, b: Vector3) -> Vector3 {
    return Vector3(storage: a.storage - b.storage)
  }

  /// Adds a vector to another in place.
  @inline(__always)
  public static func += (a: inout Vector3, b: Vector3) {
    a.storage += b.storage
  }

  /// Subtracts a vector from another in place.
  @inline(__always)
  public static func -= (a: inout Vector3, b: Vector3) {
    a.storage -= b.storage
  }

  /// Computes the cross product of two vectors.
  ///
  /// (a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x)
  public static func × (a: Vector3, b: Vector3) -> Vector3 {
    let s1 = a.storage
    let s2 = b.storage
    return Vector3(
      s1.y * s2.z - s1.z * s2.y,
      s1.z * s2.x - s1.x * s2.z,
      s1.x * s2.y - s1.y * s2.x
    )
  }

  /// Computes the dot product between two vectors.
  @inline(__always)
  public static func ° (a: Vector3, b: Vector3) -> Double {
    return (a.storage * b.storage).sum()
  }

  /// Multiplies a vector by a scalar.
  @inline(__always)
  public static func * (a: Double, b: Vector3) -> Vector3 {
    return Vector3(storage: a * b.storage)
  }

  /// Compares two vectors for equality.
  @inline(__always)
  public static func == (a: Vector3, b: Vector3) -> Bool {
    return a.storage == b.storage
  }

  /// Computes the outer product between two vectors.
  ///
  /// - Parameters:
  ///   - a: The first vector.
  ///   - b: The second vector.
  /// - Returns: A `Matrix3` representing the outer product of `a` and `b`.
  @inline(__always)
  public static func ⊗ (a: Vector3, b: Vector3) -> Matrix3 {
    return Matrix3(row0: a.storage * b.x, row1: a.storage * b.y, row2: a.storage * b.z)
  }

  // MARK: - Codable

  private enum CodingKeys: String, CodingKey {
    case x, y, z
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let x = try container.decode(Double.self, forKey: .x)
    let y = try container.decode(Double.self, forKey: .y)
    let z = try container.decode(Double.self, forKey: .z)
    self.storage = SIMD3<Double>(x, y, z)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(storage.x, forKey: .x)
    try container.encode(storage.y, forKey: .y)
    try container.encode(storage.z, forKey: .z)
  }

  /// Encodes the vector into a JSON string.
  public func jsonify() throws -> String {
    let data = try JSONEncoder().encode(self)
    if let jsonString = String(data: data, encoding: .utf8) {
      return jsonString
    } else {
      throw SpinswiftError.encodingError("Failed to encode JSON")
    }
  }
}

/// Computes the Euclidean distance between two 3D vectors.
///
/// - Parameters:
///   - a: The first vector.
///   - b: The second vector.
/// - Returns: The Euclidean distance between `a` and `b`.
@inline(__always)
public func Distance(_ a: Vector3, _ b: Vector3) -> Double {
  // Access internal storage if possible, but Vector3 is a struct now.
  // Actually we can just use operators since they are optimized.
  return (a - b).norm()
}
