/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation

/// Methods for saving and restoring data into files
///
/// The purpose of these methods is to manage data into files
/// - Author: Pascal Thibaudeau
/// - Date: 03/10/2023
/// - Version: 0.1

internal func saveOnFile(data: String, fileName: String) {
  let documentDirectory = try! FileManager.default.url(
    for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
  let fileURL = documentDirectory.appendingPathComponent(fileName).appendingPathExtension("dat")
  print("Simulation saved in \(fileURL.path)")
  do {
    // Write to a file
    try data.write(to: fileURL, atomically: true, encoding: .utf8)
  } catch {
    print("Failed writing to URL: \(fileURL), Error: \(error.localizedDescription)")
  }
}

/// A utility to stream text data to a file incrementally.
internal class FileStreamer {
  private let fileHandle: FileHandle
  private let url: URL

  init(fileName: String) throws {
    let documentDirectory = try FileManager.default.url(
      for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    self.url = documentDirectory.appendingPathComponent(fileName).appendingPathExtension("dat")

    // Create the file if it doesn't exist
    if !FileManager.default.fileExists(atPath: url.path) {
      _ = FileManager.default.createFile(atPath: url.path, contents: nil)
    }

    self.fileHandle = try FileHandle(forWritingTo: url)
    try fileHandle.truncate(atOffset: 0)  // Clear existing content
    print("Simulation streaming to \(url.path)")
  }

  internal func writeLine(_ line: String) {
    if let data = (line + "\n").data(using: .utf8) {
      fileHandle.write(data)
    }
  }

  internal func close() {
    try? fileHandle.close()
  }
}
