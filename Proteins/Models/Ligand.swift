//
//  Ligand.swift
//  Proteins
//
//  Created by Andrew Tarasow on 10.02.2022.
//

import Foundation

struct Ligand: Identifiable {
    let id = UUID()
    let name: String
    var pdbDoc: PdbDocument? = nil
    
}

