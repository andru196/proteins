//
//  PdbClient.swift
//  Proteins
//
//  Created by Andrew Tarasow on 15.02.2022.
//

import Foundation

class PdbClient {
    
    
    let pdbReader: PDBReader
    init(pdbReader: PDBReader) {
        self.pdbReader = pdbReader
    }
    
    // fake
    func getPdb(name: String) -> PdbDocument {
        let text = Files.readFile(file: "011_ideal.pdb", ext: "txt")!
        return pdbReader.read(text: text)
    }
}
