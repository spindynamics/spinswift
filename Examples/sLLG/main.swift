import Logging
import PythonKit
import Spinswift

PythonEnvironment.configure()

let logger = Logger(label: "sLLG")

let cif = Python.import("pymatgen.io.cif")

let base = cif.CifParser("Ni.cif").parse_structures(primitive: false)[0]
let structure = base.make_supercell([1, 1, 1])

logger.info("Structure = \(structure)")

let lattice = structure.lattice

logger.info("a : \(lattice.a)")
logger.info("b : \(lattice.b)")
logger.info("c : \(lattice.c)")
logger.info("alpha : \(lattice.alpha)")
logger.info("beta  : \(lattice.beta)")
logger.info("gamma : \(lattice.gamma)")

var atoms: [Atom] = []

for site in structure {
  let atom = Atom(
    name: String(site.specie.symbol)!,
    type: 1,
    position: Vector3(
      x: Double(site.frac_coords[0])!, y: Double(site.frac_coords[1])!,
      z: Double(site.frac_coords[2])!),
    moments: Atom.Moments(spin: Vector3(1, 0, 0)),
    g: 2.0)
  atoms.append(atom)
}
let Thermo: Thermostat = Thermostat(type: "classical", T: 0.1, α: 0.01)
let Δt: Double = 1E-3
let I: Interaction = Interaction(atoms)
  .zeemanField(Vector3(0, 0, 1), value: 0.1)
  .stochasticField(thermostat: Thermo, Δt: Δt)
  .dampingField(Thermo.α)

logger.info(
  "Atom 0 spin  : \(atoms[0].moments.spin.x),\(atoms[0].moments.spin.y),\(atoms[0].moments.spin.z)")
//logger.info("Atom 0 sigma : \(atoms[0].moments.sigma)")
logger.info("Atom 0 ω  : \(atoms[0].ω.x),\(atoms[0].ω.y),\(atoms[0].ω.z)")

let E: Integrate = Integrate(I)

E.evolve(
  finalTime: 2000,
  Δt: Δt,
  method: "LLG_Euler",
  file: "output",
  thermostat: Thermo)

let plt = Python.import("matplotlib.pyplot")
let np = Python.import("numpy")

let os = Python.import("os")
os.chdir(os.environ["HOME"])

let graph = np.loadtxt("./Documents/output.dat", delimiter: " ", unpack: true)

plt.plot(graph[0], graph[1], label: "Mx")
plt.plot(graph[0], graph[2], label: "My")
plt.plot(graph[0], graph[3], label: "Mz")
plt.plot(graph[0], graph[4], label: "M")

plt.title("magnetization dynamics")
plt.xlabel("time")
plt.ylabel("magnetization")
plt.legend(loc: "upper right")
plt.savefig("./Documents/output.png")
