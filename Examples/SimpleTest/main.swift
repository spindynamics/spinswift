import PythonKit
import Spinswift

PythonEnvironment.configure()

let sys = Python.import("sys")

print("Python \(sys.version_info.major).\(sys.version_info.minor)")
print("Python Version: \(sys.version)")
print("Python Encoding: \(sys.getdefaultencoding().upper())")
print("Python Path: \(sys.path)")

let num = Python.import("numpy")
let a = num.array([1,2,3])
let b = num.array([4,5,6])
let c = a + b 
print(c)

let pym = Python.import("pymatgen.io.cif")
let cif = pym.CifParser("./SimpleTest/Ni.cif")
print(cif.parse_structures(primitive:false)[0])
print(cif.parse_structures(primitive:true)[0])

print("Planck constant in SI = \(k_B.value / Joule.value)")
