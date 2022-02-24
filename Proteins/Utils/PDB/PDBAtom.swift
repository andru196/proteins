//
//  PDBAtom.swift
//  Proteins
//
//  Created by Andrew Tarasow on 22.02.2022.
//

import Foundation

struct PDBAtom: Equatable {
    let name: String
    let element: String
    let number: Int
    let x: Double
    let y: Double
    let z: Double
}
