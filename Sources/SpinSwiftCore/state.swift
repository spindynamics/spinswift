/*
//  Copyright (C) 2020 Pascal Thibaudeau.
//
// This software is a computer program whose purpose is Spinswift.
//
// This software is governed by the CeCILL license under French law and
// abiding by the rules of distribution of free software. You can use,
// modify and/ or redistribute the software under the terms of the CeCILL
// license as circulated by CEA, CNRS and INRIA at the following URL
// "http://www.cecill.info".
//
// As a counterpart to the access to the source code and rights to copy,
// modify and redistribute granted by the license, users are provided only
// with a limited warranty and the software's author, the holder of the
// economic rights, and the successive licensors have only limited
// liability.
//
// In this respect, the user's attention is drawn to the risks associated
// with loading, using, modifying and/or developing or reproducing the
// software by the user in light of its specific status of free software,
// that may mean that it is complicated to manipulate, and that also
// therefore means that it is reserved for developers and experienced
// professionals having in-depth computer knowledge. Users are therefore
// encouraged to load and test the software's suitability as regards their
// requirements in conditions enabling the security of their systems and/or
// data to be ensured and, more generally, to use and operate it in the
// same conditions as regards security.
//
// The fact that you are presently reading this means that you have had
// knowledge of the CeCILL license and that you accept its terms.
//
//  state.swift
//  Spinswift
//
//  Created by Pascal Thibaudeau on 24/03/2017.
*/

/*
The spinswift core library functions around a *simulation state*.
The `State` is the object that holds every information needed for the simulation
of the spin system. Currently a `State` can contain only one `Chain` which
contains all the images (spin systems) of the simulation.
One can easily understand the structure by looking at the following diagram:

```
+-----------------------------+
| State                       |
| +-------------------------+ |
| | Chain                   | |
| | +--------------------+  | |
| | | 0th System ≡ Image |  | |
| | +--------------------+  | |
| | +--------------------+  | |
| | | 1st System ≡ Image |  | |
| | +--------------------+  | |
| |   .                     | |
| |   .                     | |
| |   .                     | |
| | +--------------------+  | |
| | | Nth System ≡ Image |  | |
| | +--------------------+  | |
| +-------------------------+ |
+-----------------------------+
```
*/

import Foundation

/*
State
The State class is passed around in an application to make the
simulation's state available.
The State contains all necessary Spin Systems (via chain and collection)
and provides a few utilities (pointers) to commonly used contents.
*/

struct state {
  var activeState = [Atom]()

  init(){} // Initialize a state
  init(withFile: String){} // Create new state by passing a config file

  func update(){} // Update the state to hold current values
  func delete(){} // Delete a state
  func write(){} // Write a config file which will result in the same state if used in setup()
  func date(){} // datetime tag of the creation of the state
}
