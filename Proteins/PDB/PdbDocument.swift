//
//  PdbDocument.swift
//  Proteins
//
//  Created by Andrew Tarasow on 22.02.2022.
//

import Foundation

struct PdbDocument {
    let atoms: [PDBAtom]
    var connections: [PDBConnect]
}
