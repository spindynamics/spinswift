import Foundation
import Logging
import Spinswift

PythonEnvironment.configure()

let logger: Logger = Logger(label: "CurieTemperatureNi")

struct SimulationConfig {
  var method: String
  var element: String
  var exchangeCoupling: Double
  var temperatureRange: (initial: Double, step: Double, final: Double)
  var timeStep: Double
  var simulationTime: Double
  var thermostat: Thermostat
  var supercellSize: (x: Int, y: Int, z: Int)
}

func runSimulation(config: SimulationConfig) throws -> SimulationProgram {
 
  // 1. Initialize simulation program inputs
  let simulationInputs: SimulationProgram.Inputs = SimulationProgram.Inputs(
    method: config.method,
    initialTemperature: config.temperatureRange.initial,
    ΔT: config.temperatureRange.step,
    finalTemperature: config.temperatureRange.final,
    Δt: config.timeStep,
    finalTime: config.simulationTime,
    thermostat: config.thermostat
  )
  // 2. Generate crystal structure (using CIFReader)
  let reader: CIFReader = CIFReader()
  let cifData: CIFReader.CrystallographicData = try reader.read(filePath: "CurieTemperatureNi/" + config.element + ".cif")
  let unitCellAtoms: [Atom] = cifData.atoms

  let latticeConstant: Double = 0.1 * (cifData.lattice.a)

  // Define initial parameters for the atoms (Nickel)
  let initialParameters: InitialParameters = InitialParameters(
    name: config.element,
    type: 1,
    moments: Atom.Moments(spin: Vector3(1, 0, 0), sigma: Matrix3(fill: "identity")),
    g: 2.0
  )

  // Generate supercell with Cartesian coordinates
  let crystalStructure: [Atom] = GenerateCrystalStructure(
    UCAtoms: unitCellAtoms,
    supercell: config.supercellSize,
    LatticeConstant: latticeConstant,
    initialParameters: initialParameters
  )

  logger.info("Generated crystal structure with \(crystalStructure.count) atoms.")
  logger.info("Lattice constant: \(cifData.lattice.a) Å")

  // 3. Set up boundary conditions
  let boundaries: BoundaryConditions = BoundaryConditions(
    BoxSize: latticeConstant
      * Vector3(
        Double(config.supercellSize.x),
        Double(config.supercellSize.y),
        Double(config.supercellSize.z)
      ),
    PBC: "on"
  )
  // 4. Set up interactions
  let J_ij: Double = config.exchangeCoupling / ℏ.value
  let interaction: Interaction = Interaction(crystalStructure)
    .exchangeField(
      typeI: 1,
      typeJ: 1,
      value: J_ij,
      cutoffRadius: latticeConstant * 0.7072,  // Nearest neighbor distance in FCC
      boundaryConditions: boundaries
    )
  // 5. Set up integration
  let integrator: Integrate = Integrate(interaction)
  // 6. Run simulation
  let simulation: SimulationProgram = SimulationProgram(integrator)
  simulation.simulate(Program: "curie_temperature", IP: simulationInputs)
  return simulation
}

// Main execution

let config: SimulationConfig = SimulationConfig(
  method: "dLLB_Euler",
  element: "Ni",
  exchangeCoupling: 17.2,
  temperatureRange: (initial: 0, step: 50, final: 50),
  timeStep: 1e-2,
  simulationTime: 10,
  thermostat: Thermostat(type:"classical",Tc:635,T:0,α:0.1),
  supercellSize: (x: 3, y: 3, z: 3)
)

let sortie: SimulationProgram = try runSimulation(config: config)
