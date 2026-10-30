# SpinSwift

Atomistic spin dynamics simulation in Swift. Simulates magnetic properties of materials including the Curie temperature, ultrafast magnetization dynamics, and spin transport in crystalline structures.

![SpinSwift](https://mark.sylphx.com/api/v1/mark/hero.svg?text=SpinSwift&desc=Atomistic+spin+dynamics+simulation+in+Swift&theme=light)

## Overview

SpinSwift is a command-line application for atomic spin simulations targeting macOS and Debian 12/13 platforms. It includes:

- **Curie Temperature**: Simulates Nickel's phase transition in FCC crystal lattices
- **Optical Pulse**: Models laser pulse effects on magnetization using Two-Temperature Models
- **Time Dynamics**: Simulates single spin evolution under various magnetic interactions
- **Paramagnetic Spins**: Studies thermal effects on multi-spin systems
- **Macrospin**: Simplified single-particle spin dynamics with dLLB equation

The project uses the GNU Scientific Library (GSL) for numerical calculations and PythonKit for Python interoperability.

## Installation

### Prerequisites

- Swift 6.3 or later
- GNU Scientific Library (GSL) installed on your system
- Python 3.13+ with uv package manager
- Docker or Podman for containerized builds

### Quick Start (Docker/Podman)

No local Swift compiler installation required. Use a container:

```bash
podman build -t spinswift . && \
podman run -it --rm -v.:/workdir:z --name spinswift spinswift
```

### Local Build

**Install dependencies:**
```bash
# macOS
brew install gsl

# Debian/Ubuntu
sudo apt-get install libgsl-dev
```

**Clone and build:**
```bash
git clone <repository-url>
cd spinswift
swift build
```

### Python Environment

The project uses `uv` for Python package management. Ensure `.python-version` and `.venv` files are present in the project root.

```bash
uv sync
source .venv/bin/activate
```

## Usage

### Running Examples

Navigate to the Examples directory and run simulations:

```bash
cd Examples/CurieTemperatureNi
swift run
```

Other available examples:
- `SimpleTest`: Quick environment verification
- `sLLG`: Stochastic Landau-Lifshitz-Gilbert dynamics visualization

### Running Tests

```bash
PYTHON_LOADER_LOGGING=TRUE PYTHON_VERSION=$(cat .python-version) swift test
```

### Documentation

**Generate documentation:**
```bash
swift package generate-documentation
```

**Preview documentation:**
```bash
swift package --disable-sandbox preview-documentation --target spinswift
```

## Project Structure

- **Sources/spinswift/core/**: Core simulation components
  - `Atom.swift`: Spin dynamics and thermal models
  - `SimulationProgram.swift`: Simulation program management
  - `Interaction.swift*: magnetic interaction models
  - `Integration.swift`: Numerical integration methods
  - `Analysis.swift`: Magnetic property analysis
  - `Constants.swift`: Physical constants
  - `Configuration.swift*: Crystal structure generation
  - `LaserHeating.swift*: Ultrafast magnetization simulations

For complete documentation, see [AGENTS.md](AGENTS.md).

## Features

### Physical Models

- **dLLB Equation**: Dynamic Landau-Lifshitz-Bloch equation for spin dynamics
- **Two/Three-Temperature Models**: Electron-phonon/spin temperature evolution
- **Exchange Interactions**: Heisenberg coupling between spins
- **Dzyaloshinskii-Moriya Interaction (DMI)**: Chiral spin interactions
- **Zeeman Field**: External magnetic field effects
- **Spin-Transfer Torque**: Field-like and damping-like STT components
- **Various Integration Methods**: Euler, RK4, and symplectic integrators

### Mathematical Foundation

- Vector and matrix algebra operations
- Gauss-Legendre quadrature integration
- Statistical mechanics calculations
- Quantum statistical distributions

## Contributing

Contributions are welcome! See [AGENTS.md](AGENTS.md) for development guidelines, testing requirements, and project conventions.

## License

This project is licensed under the **Creative Commons Attribution-ShareAlike 4.0 International License**.

### Key Rights
- **Attribution**: You must give appropriate credit and indicate any changes made
- **ShareAlike**: You may use this work for any purpose, including commercially
- **Share**: You must distribute your contributions under the same license

### Terms
- You may copy, distribute, display, perform, and modify the work
- You must attribute the original creator(s)
- If you modify the work, you must distribute your modification under the same license
- The license allows commercial use and derivative works

### Full License Text
For the complete and current license terms, see the full text in [`LICENSE.md`](LICENSE.md).

### Example Attribution
```
SpinSwift - Atomistic spin dynamics simulation
Copyright (c) [Year(s)] [Your Name/Distributor]
Licensed under CC BY-SA 4.0
https://github.com/yourusername/spinswift
```
