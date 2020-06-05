import Foundation

public func saveOnFile(data: String, fileName: String) {

//let desktop = URL(fileURLWithPath: "/home/maintenance/Travail")

let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
    let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("dat")
    
    print("Simulation saved in \(fileURL.path)")

    do {
        // Write to the file
        try data.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch let error as NSError {
          print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
    } 
}