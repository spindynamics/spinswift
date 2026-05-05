/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/

/// Errors that can occur within the Spinswift library.
public enum SpinswiftError: Error, CustomStringConvertible {
  /// Occurs when JSON encoding or decoding fails.
  case encodingError(String)

  public var description: String {
    switch self {
    case .encodingError(let message):
      return "Encoding Error: \(message)"
    }
  }
}
