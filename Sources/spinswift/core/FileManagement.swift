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

func saveOnFile(data: String, fileName: String) {
    let documentDirectory = try! FileManager.default.url(
        for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let fileURL = documentDirectory.appendingPathComponent(fileName).appendingPathExtension("dat")
    print("Simulation saved in \(fileURL.path)")
    do {
        // Write to a file
        try data.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch let error as NSError {
        print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
    }
}
