/*
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*/
import Foundation
/// This class for managing The general settings of spinswift code
/// All general settings regarding format, strucutre, color and generalities is done here
/// - Author: Mouad Fattouhi 
/// - Date: 01/08/2024
/// - Version: 0.1

class GeneralSettings : Codable {

 struct WriteCol {
     static let reset = "\u{001B}[0;0m"
     static let black = "\u{001B}[0;30m"
     static let red = "\u{001B}[0;31m"
     static let green = "\u{001B}[0;32m"
     static let yellow = "\u{001B}[0;33m"
     static let blue = "\u{001B}[0;34m"
     static let magenta = "\u{001B}[0;35m"
     static let cyan = "\u{001B}[0;36m"
     static let white = "\u{001B}[0;37m"
 }

 struct WriteFont {
     static let bold = ""
     static let Italic = ""
}

}
