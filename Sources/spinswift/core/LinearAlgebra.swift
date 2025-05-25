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
func distance(_ a: Vector3, _ b: Vector3) -> Double {
    return ((a - b) ° (a - b)).squareRoot()
}
