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

class Ligands: ObservableObject {
    @Published var items: [Ligand]
    
    init(names: [String]) {
        var _items = [Ligand]()
        for name in names {
            _items.append(Ligand(name: name))
        }
        items = _items
    }
}
