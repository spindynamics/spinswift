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
//  Constants.swift
//  Spinswift
//
//  Created by Pascal Thibaudeau on 24/06/2019.
*/

// a very small number
let ε   = 1e-18

public struct PhysicalConstants {
  let elementary_charge = (value: 1.602176634e-19, description: "The elementary charge", units:"A s")
  let μ_B = (value: 0.057883817555, description: "The Bohr Magneton", units:"[meV/T]")
  let μ_0 = (value: 2.0133545*1e-28, description: "The vacuum permeability", units:"[T^2 m^3 / meV]")
  let k_B  = (value: 0.08617330350, description: "The Boltzmann constant", units:"[meV/K]")
  let ℏ = (value: 0.6582119514, description: "The Planck constant", units:"[meV*ps/rad]")
}

public struct PrecessionConstants {
  let g_e = (value: 2.00231930436182, description: "The electron (Landé) g-factor", units:"[unitless]")
  let γ = (value: 0.1760859644, description: "The gyromagnetic ratio of electron", units:"[rad/(ps*T)]")
}

public struct ConversionFactors { 
  let mRy = (value: 1.0/13.605693009, description: "milliRydberg", units:"[mRy/meV]")
  let erg = (value: 6.2415091*1e14, description: "erg", units:"[erg/meV]")
  let Joule = (value: 1e-3/PhysicalConstants().elementary_charge.value, description:"Joule", units:"[J/meV]")
}
