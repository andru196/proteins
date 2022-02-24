//
//  Configurator.swift
//  Proteins
//
//  Created by Andrew Tarasow on 15.02.2022.
//

import Foundation

class Configurator {
    private static var _isInited = false
    private static var _pdbClient: PdbClient!
    private static var _pdbReader: PDBReader!
    private static var _ligandViewModel: LigandViewViewMode!
    private static var _sceneConstructor: SceneConstructor!
    private static var _atomsInfo: [String : AtomInfo]!
    private static var _loginableModel: Model!
    private static var _ligands: Ligands!
    
    static func getClient() -> PdbClient {
        return  _pdbClient
    }
    
    static func getReader() -> PDBReader {
        return _pdbReader
    }
    
    
    static func getAtomsInfo() -> [String : AtomInfo] {
        _atomsInfo
    }
    
    static func getLigandViewViewModel() -> LigandViewViewMode {
        return _ligandViewModel
    }
    
    static func getLoginableModel() -> Model {
        _loginableModel
    }
    
    static func getSceneConstructor() -> SceneConstructor {
        _sceneConstructor
    }
    
    static func getLigands() -> Ligands {
        _ligands
    }
    
    
    private static var _loginViewBox: Box<LoginView>!
    static func getLoginView() -> LoginView {
        _loginViewBox = Box(value: LoginView(model: _loginableModel))
        _loginViewBox.value.lock(nextView: getListView())
        return _loginViewBox.value!
    }
    
    static func getListView() -> LigandsListView {
        LigandsListView(ligands: _ligands,
                        logView: _loginViewBox)
    }
    
    static func getLigandView() -> LigandView {
        LigandView(modelView: _ligandViewModel,
                   logBox: _loginViewBox)
    }
    
    static func configure() {
        if !_isInited {
            _pdbReader = PDBReader()
            _pdbClient = PdbClient(pdbReader: _pdbReader)
            _atomsInfo = Files.readAtomInfos()
            _loginableModel = Model()
            _sceneConstructor = SceneConstructor(atomInfos: _atomsInfo)
            _ligandViewModel = LigandViewViewMode(constructor: _sceneConstructor, atomInfos: _atomsInfo, client: _pdbClient, loginableModel: _loginableModel)
            _ligands = Ligands(names: Files.readLigandsList())
            _isInited = true
        }
    }
}
