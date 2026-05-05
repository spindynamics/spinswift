# AGENTS.md

## Project Overview

This project, `spinswift`, is a command-line application written in Swift for performing atomic spin simulations. It targets the MacOS and Debian 12/13 platforms. Based on the source code, it appears to be a tool for solid-state physics research, specifically for simulating properties of magnetic materials. The main application simulates the behavior of Nickel in a face-centered cubic (FCC) crystal lattice to determine its Curie temperature. The project relies on the GNU Scientific Library (GSL) and PythonKit for numerical calculations and Python interoperability, respectively.
The interoperability with python is performed by using the astral-uv package manager for adding python modules. The project uses the `Uv.swift` component to automatically configure the Python environment by detecting the project root via `.python-version` and `.venv` files.
First be sure to synchronize the requested python modules by running the following command:

```bash
source .venv/bin/activate
uv sync
```

## Building and Running

The project uses the Swift Package Manager for building, running, and testing.

### Building

To build the project library, ensure you have Swift 6.3 or later installed. Then run the following command:

```swift
swift build
```

### Running

To run the simulation programs that use the library, use the following command:

```bash
source .venv/bin/activate
cd Examples/CurieTemperatureNi
swift build
swift run
```

### Testing

To run the test suite for the library, use the following command:

```swift
PYTHON_LOADER_LOGGING=TRUE PYTHON_VERSION=$(cat .python-version) swift test
```

### Documentation

To generate and preview the documentation, use the following commands:

```swift
swift package generate-documentation
swift package --disable-sandbox preview-documentation --target spinswift
```

## Development Conventions

*   **Testing:** The project uses the Swift Testing framework for comprehensive testing. Test coverage includes:
    - **Unit Tests**: Individual component testing for periodic table data, linear algebra operations, and spin dynamics
    - **Precision Tests**: Floating-point calculations with strict tolerances (1e-15 for GSL, 1e-9 for linear algebra)
    - **Integration Tests**: GSL library integration with tests for Bessel, exponential, error, gamma, trigonometric, logarithmic, and power functions
    - **Property Tests**: Mathematical property verification including matrix trace, determinant, inverse, and operator overloading
*   **Dependencies:** The project has system dependencies on the GNU Scientific Library (GSL) and PythonKit. GSL must be installed on the system, and `Package.swift` specifies how to locate it using `pkg-config`. PythonKit is a Swift Package Manager dependency.
*   **Code Structure:** The core functionalities are abstracted into different files within the `Sources/Spinswift/core/` directory. Each file has to be formatted using `swift-format -i file.swift`

## Core Components

### Main Simulation Files


1. **Atom.swift** - Manages atomic properties and spin dynamics:
   - Atomic structure with position, spin moments, and physical properties
   - Implementation of the dLLB (dynamic Landau-Lifshitz-Bloch) equation
   - Quantum and classical thermostat models
   - Integration methods (Euler, RK4, Symplectic, and closed-form solutions)

2. **SimulationProgram.swift** - Manages different simulation programs:
   - **Curie Temperature**: Simulates multi-spin dynamics with temperature sweep
   - **Optical Pulse**: Simulates laser pulse effects on magnetization
   - **Time Dynamics**: Simulates single spin dynamics
   - **Paramagnetic Spins**: Simulates multi-spin systems without exchange interactions
   - **Macrospin**: Simplified single-particle model

3. **Interaction.swift** - Manages interactions between atoms:
   - Exchange interactions
   - Dzyaloshinskii-Moriya Interaction (DMI)
   - Zeeman field
   - Damping
   - Uniaxial anisotropy
   - Demagnetizing field
   - Stochastic field (thermal field)
   - Spin-transfer torque (STT) supporting field-like and damping-like amplitudes
   - Field recalculation and state management through `update()` and JSON serialization

4. **Integration.swift** - Handles numerical integration:
   - Euler integration
   - Runge-Kutta 4th order (RK4) integration
   - Symplectic evolution methods (`evolveSymplectic`)
   - Time evolution of spin systems

5. **Analysis.swift** - Provides analysis tools:
   - Magnetization calculation
   - Magnetic susceptibility
   - Spin temperature calculation
   - Energy and torque analysis

### Supporting Files

6. **PeriodicTable.swift** - Comprehensive periodic table data:
   - Atomic numbers and symbols
   - Atomic masses
   - Atomic radii (empirical, calculated, van der Waals)
   - Lookup functions for element properties

7. **Constants.swift** - Physical constants:
   - Elementary charge
   - Bohr magneton
   - Boltzmann constant
   - Planck constant
   - Gyromagnetic ratio
   - Conversion factors

8. **Configuration.swift** - Crystal structure generation and Configuration:
   - **CIFReader**: Reads Crystallographic Information Files (.cif) using Pymatgen to extract lattice parameters, atomic positions, and symmetry data.
   - Unit cell definitions and Supercell generation
   - Atom substitution methods (Random and Specific)
   - Boundary conditions
   - Distance calculations with periodic boundary conditions

9. **LaserHeating.swift** - Laser excitation and heating:
    - Two-Temperature (2TM) and Three-Temperature (3TM) models
    - Gaussian pulse simulation
    - Electron-phonon coupling
    - Temperature evolution with different integration methods

10. **FileManagement.swift** - Data I/O:
    - Save simulation results to files
    - File handling utilities

11. **VectorLinearAlgebra.swift** - 3D vector operations:
    - Vector arithmetic (addition, subtraction)
    - Cross and dot products
    - Outer products
    - Distance calculations
    - Normalization

12. **MatrixLinearAlgebra.swift** - 3x3 matrix operations:
    - Matrix arithmetic
    - Trace, determinant, inverse
    - Transpose, cofactor, adjoint
    - Matrix-vector multiplication
    - Matrix exponentiation

13. **Thermostat.swift** - Thermostat models:
    - Classical thermostat
    - Quantum thermostat (quadratic and quartic)
    - Thermal coefficient calculations
    - Gauss-Legendre integration

14. **Uv.swift** - Python environment management:
    - Provides `PythonEnvironment.configure()` to automate `PythonKit` setup
    - Locates the project root by searching parent directories for `.python-version` and `.venv`
    - Automatically discovers the corresponding `uv`-managed Python installation in `~/.local/share/uv/python`
    - Sets the `PYTHON_LIBRARY` environment variable and initializes `sys.path`, ensuring the project's virtual environment site-packages are included

15. **Miscellaneous.swift** - Miscellaneous utilities:
    - Additional helper functions and utilities

16. **Errors.swift** - Error handling:
    - SpinswiftError enum for JSON encoding/decoding errors
    - Custom error descriptions

## Simulation Programs

The project supports multiple simulation programs:

### 1. Curie Temperature
Simulates multi-spin dynamics with temperature sweep to determine the Curie curve.
- Sweeps temperature from T_initial to T_final
- Calculates magnetization and susceptibility
- Outputs magnetization vs temperature data

### 2. Optical Pulse
Simulates laser pulse effects on magnetization:
- Gaussian pulse excitation
- Two-Temperature (2TM) and Three-Temperature (3TM) Models for electron, phonon, and spin dynamics
- Electron-phonon coupling
- Magnetization dynamics under laser heating

### 3. Time Dynamics
Simulates single spin dynamics:
- Time evolution of individual spins
- Various magnetic interactions
- Integration over specified time intervals

### 4. Paramagnetic Spins
Simulates multi-spin systems without exchange interactions:
- Paramagnetic behavior
- Thermal effects on spin orientation
- Susceptibility calculations

### 5. Macrospin with dLLB
Simplified single-particle model:
- Single spin dynamics
- User-defined external fields
- Basic integration methods

## Key Features

- **Multi-scale simulations**: From single spins to crystal lattices
- **Quantum/Classical Thermostats**: with Electron/Phonon/Spin Temperature Models (2TM/3TM)
- **Multiple integration methods**: Euler, RK4, and Symplectic integrators for different accuracy and stability needs
- **Comprehensive analysis**: Magnetization, energy, susceptibility
- **Crystal structure generation**: FCC, BCC, and custom lattices
- **Laser heating simulations**: For ultrafast magnetism studies
- **Periodic boundary conditions**: For realistic bulk material simulations
- **Extensive testing**: Unit tests for core functionality

## Physical Models

The project implements several key physical models:

1. **dLLB Equation**: Dynamic Landau-Lifshitz-Bloch equation for spin dynamics ([see dLLBS](https://arxiv.org/abs/2510.04562)) 
2. **Two-Temperature and Three-Temperature Models (TTM/3TM)**: For laser heating simulations ([see applications](https://arxiv.org/abs/2502.07375))
3. **Exchange Interactions**: Heisenberg exchange between spins
4. **Dzyaloshinskii-Moriya Interaction (DMI)**: Chiral interaction between neighboring spins
5. **Zeeman Field**: External magnetic field effects
6. **Anisotropy**: Uniaxial magnetic anisotropy
7. **Demagnetizing Field**: Shape anisotropy effects
8. **Spin-Transfer Torque (STT)**: Includes both field-like and damping-like torque components

## Mathematical Foundation

The codebase includes robust mathematical implementations:
- Vector and matrix algebra
- Numerical integration methods (including symplectic integrators)
- Statistical mechanics calculations
- Quantum statistical distributions
- Integration using Gauss-Legendre quadrature

## Examples

The project includes example implementations in the `Examples/` directory:

### CurieTemperatureNi
This example demonstrates a Nickel Curie temperature simulation:
- **main.swift**: Main simulation program for Nickel FCC crystal. It loads the crystal structure from `Ni.cif` using the `CIFReader` class.
- **Package.swift**: Swift Package configuration for the example

### sLLG
Advanced example demonstrating stochastic Landau-Lifshitz-Gilbert dynamics:
- Loads Nickel FCC structure and creates a supercell
- Uses symplectic integration for magnetization dynamics
- Real-time visualization using `matplotlib` via `PythonKit`

### SimpleTest
Minimal example verifying the environment:
- Checks Python interoperability and `numpy` integration
- Validates CIF file parsing using `pymatgen`

## Testing Strategy

The project uses the Swift Testing framework. The test suite is located in `Tests/spinswiftTests/spinswiftTests.swift` and provides comprehensive coverage of the application's core functionalities.

### Unit and Precision Tests
-   **Periodic Table Data**: Verifies the accuracy of element data lookups, such as atomic radius and symbol (`testPeriodicTable`).
-   **Linear Algebra Operations**: Covers `Matrix3` and `Vector3` operations, including initializers, arithmetic operators (+, -, *, **), and mathematical properties (trace, determinant, inverse, etc.). Precision for floating-point comparisons is set to `1e-9` (`testLinearAlgebra`).
-   **Spin Dynamics Model**: Ensures the `rhs` (right-hand side) method for the quantum thermostat produces valid, non-NaN results for spin and sigma moments (`testRHSWithQuantumThermostat`).

### Integration Tests
-   **GNU Scientific Library (GSL)**: Validates the correctness of various GSL special functions (Bessel, gamma, erf, etc.) by comparing them against known values with a strict tolerance of `1e-15` (`testGSL`).
-   **Python Interoperability (PythonKit & Pymatgen)**:
    -   Confirms that Swift can correctly interact with Python libraries via `PythonKit`.
    -   The test (`testPymatgenCoreStructureLattice`) dynamically modifies Python's `sys.path` to include the project's virtual environment (`.venv/lib/python3.13/site-packages`), ensuring `pymatgen` is importable.
    -   It loads an iron crystal structure from a CIF file (`Assets/Fe.cif`) using `pymatgen.core.Structure.from_file`.
    -   It verifies the loaded structure's lattice parameters (a, b, c, alpha, beta, gamma) and confirms that the atomic species is correctly identified as Iron ("Fe").
