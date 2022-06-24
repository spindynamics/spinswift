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
//  region.swift
//  Spinswift
//
//  Created by Pascal Thibaudeau on 24/03/2017.
*/

public class Region {
    
    var p1, p2: Vector3

    public init(p1: Vector3, p2: Vector3){
        self.p1 = p1
        self.p2 = p2
    }

    convenience init(){
        self.init(p1: Vector3(0,0,0), p2: Vector3(1,1,1))
    }

    public func Volume()-> Double {
        let v = (p2.x-p1.x)*(p2.y-p1.y)*(p2.z-p1.z)
        guard  v != 0 else {fatalError("Volume is zero")}
        return v
    }

}