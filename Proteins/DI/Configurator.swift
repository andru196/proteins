//
//  Configurator.swift
//  Proteins
//
//  Created by Andrew Tarasow on 15.02.2022.
//

import Foundation

class Configurator {
    private static var _pdbClient: PdbClient!
    private static var _pdbReader: PDBReader!
    
    static func getClient() -> PdbClient {
        return  _pdbClient
    }
    
    static func getReader() -> PDBReader {
        return _pdbReader
    }
    
    static func configure() {
        _pdbReader = PDBReader()
        _pdbClient = PdbClient(pdbReader: _pdbReader)
    }
}
