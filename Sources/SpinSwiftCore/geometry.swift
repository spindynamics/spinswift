/*
//  Copyright (C) 2017 Pascal Thibaudeau.
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
//  geometry.swift
//  Spinswift
//
//  Created by Pascal Thibaudeau on 24/03/2017.
*/

public class Geometry {
  public var r = [Vector3]()
  var cell = [1,1,1]
  var pbc = [false,false,false]
  
  public init(){}

  public init(p1: Vector3, p2: Vector3, cell: [Int], pbc: [Bool]){
    let region = Region(p1:p1, p2:p2)
    self.pbc = pbc
    generate(region:region, cell: cell)
  }
  
  public init(region: Region, cell: [Int], pbc: [Bool]){
    self.pbc = pbc
    generate(region: region, cell: cell)
  }
  
  func generate(region: Region, cell: [Int]){
    let p1 = region.p1
    let p2 = region.p2
    if cell.count == 3  {
      for i in 0...(cell[0]-1) {
        let x1 = (p2.x - p1.x)*Double(i)/Double(cell[0])+p1.x
        for j in 0...(cell[1]-1) {
          let y1 = (p2.y - p1.y)*Double(j)/Double(cell[1])+p1.y
          for k in 0...(cell[2]-1) {
            let z1 = (p2.z - p1.z)*Double(k)/Double(cell[2])+p1.z
            r.append(Vector3(x:x1, y:y1, z:z1))
          }
        } 
      } 
      self.cell = cell
    } else {fatalError("Error in cell dimensions")}
  }

  public func Print(){
    for (index,item) in r.enumerated() {print("r[\(index)]=<\(item.x),\(item.y),\(item.z)>")}
  }

  public func Distance(atom1: Int, atom2: Int) -> Double {
    /*
    r[atom1].x -= ((r[atom1].x)/Double(cell[0])).rounded(.down)*Double(cell[0])
    r[atom1].y -= ((r[atom1].y)/Double(cell[1])).rounded(.down)*Double(cell[1])
    r[atom1].z -= ((r[atom1].z)/Double(cell[2])).rounded(.down)*Double(cell[2])
    r[atom2].x -= ((r[atom2].x)/Double(cell[0])).rounded(.down)*Double(cell[0])
    r[atom2].y -= ((r[atom2].y)/Double(cell[1])).rounded(.down)*Double(cell[1])
    r[atom2].z -= ((r[atom2].z)/Double(cell[2])).rounded(.down)*Double(cell[2])
    */
    let rij = r[atom2] - r[atom1]

    if pbc.count == 3 {
      if pbc[0] == true {
        rij.x -= Double(cell[0])*(rij.x/Double(cell[0])).rounded() 
      }
      if pbc[1] == true {
        rij.y -= Double(cell[1])*(rij.y/Double(cell[1])).rounded() 
      }
      if pbc[2] == true {
        rij.z -= Double(cell[2])*(rij.z/Double(cell[2])).rounded() 
      }
    } else {fatalError("pbc is not properly formatted")}
    return (rij.Norm())
  }

}
