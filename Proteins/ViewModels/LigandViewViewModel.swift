//
//  LigandViewViewModel.swift
//  Proteins
//
//  Created by Andrew Tarasow on 23.02.2022.
//

import SwiftUI
import SceneKit

final class LigandViewViewMode: ObservableObject {
    
    @Published private(set) var isSelectedElement: Bool = false
    @Published private(set) var showInfo: Bool = false
    @Published private(set) var dataLoaded: Bool = false
    @Published var scnView: ScenekitView!
    @Published private(set) var showHydrogens = false
    
    private let atomInfos: [String: AtomInfo]
    private let loginableModel: Model
    private let constructor: SceneConstructor
    private let client: PdbClient
    
    var allAtoms = [SCNNode: PDBAtom]()
    var selectedAtom: PDBAtom?
    var selectedAtomInfo: AtomInfo?
    var ligand: Ligand?
    
    
    init(constructor: SceneConstructor,
         atomInfos: [String: AtomInfo],
         client: PdbClient,
         loginableModel: Model
    ) {
        self.atomInfos = atomInfos
        self.client = client
        self.constructor = constructor
        self.loginableModel = loginableModel
    }
    
    func selected(selectedElement: SCNNode?) {
        isSelectedElement = true
        if let _ = selectedElement?.geometry as? SCNSphere? {
            if let sE = selectedElement {
                if let atom = allAtoms[sE] {
                    self.selectedAtom = atom
                    self.selectedAtomInfo = atomInfos[atom.element]
                    showInfo = true
                    return
                }
            }
        }
        showInfo = false
        self.selectedAtom = nil
        self.selectedAtomInfo = nil
        
        
    }
    
    func unselected() {
        isSelectedElement = false
        showInfo = false
        self.selectedAtom = nil
        self.selectedAtomInfo = nil
    }
    
    func loadData(ligand: Ligand) -> Bool {
        dataLoaded = false
        self.ligand = ligand
        let boxDoc = Box(value: client.gePdb(name: ligand.name))
        if boxDoc.value == nil || boxDoc.value.atoms.isEmpty || boxDoc.value.connections.isEmpty {
            return false
        }
        let _ = constructor.recursiveCheck(doc: boxDoc)
        self.ligand!.pdbDoc = boxDoc.value
        let boxLig = Box(value: self.ligand)
        let scene = SCNScene()
        self.allAtoms = constructor.generate(scene: scene, ligandBox: boxLig)
        scnView = ScenekitView(scenekitClass: ScenekitClass(scene:  scene, viewModel: self))
        objectWillChange.send()
        DispatchQueue.main.async {
            self.dataLoaded = true
        }
        
        showHydrogens = false
        toggleShowHydrogens()
        return true
    }
    
    func randColor() {
        let colors = [UIColor.black,
                      UIColor.gray,
                      UIColor.blue,
                      UIColor.darkGray,
                      UIColor.magenta,
                      UIColor.purple,
                      UIColor.yellow,
                      UIColor.green,
                      UIColor.red,
                      UIColor.white]
        scnView.scenekitClass.scene.background.contents = colors.randomElement()
    }
    
    func toggleShowHydrogens() {
        for atom in allAtoms {
            if atom.value.element.uppercased() == "H" {
                atom.key.isHidden = !showHydrogens
            }
        }
        showHydrogens.toggle()
    }
    
    @discardableResult
    func share() -> Bool {
        let items = [scnView.scenekitClass.view.snapshot(), self.ligand!.name] as [Any]
        let excludedActivityTypes = [.postToFlickr] as [UIActivity.ActivityType]
        guard let source = UIApplication.shared.currentUIWindow()?.rootViewController else {
            return false
        }
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        vc.excludedActivityTypes = excludedActivityTypes
        vc.popoverPresentationController?.sourceView = source.view
        source.present(vc, animated: true)
        return true
    }
    
}
