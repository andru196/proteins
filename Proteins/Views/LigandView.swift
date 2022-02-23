//
//  LigandView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 10.02.2022.
// http://files.rcsb.org/ligands/view/\(filteredNames[index])_ideal.pdb

import SwiftUI
import SceneKit
import Foundation

struct LigandView: BaseView {
    var loginableModel: Model
    @Environment(\.presentationMode) var presentationMode
    let id = UUID()
    var scenePhase: ScenePhase! {
        didSet {
            lock()
        }
    }
    
    @Environment(\.scenePhase) var _scenePhase {
        
        didSet {
            lock()
        }
    }
    
    var loginView: Box<LoginView>
    var client: PdbClient!
    
    @State var showInfo: Bool = false
    //@State var scene = SCNScene()
    @State var selectedElement: Node? = nil {
        mutating didSet {
            if let atom = selectedElement?.scnNode {
                selectedAtom = allAtoms.value[atom]
            }
        }
    }
    
    var selectedAtom: PDBAtom?
    var allAtoms = Box(value: [SCNNode: PDBAtom]())
    //    var _scnView: ScenekitView!
    private let atomInfos: [String: AtomInfo]
    var scnViewBox = Box<ScenekitView>()
    
    
    
    func updateSelectionBind() -> ScenekitView {
        if scnViewBox.value != nil {
            scnViewBox.value.updateSelectionBind(isSelectedElement: $showInfo)
        }
        return scnViewBox.value
    }
    
    //    var ligand: Ligand!
    @ObservedObject
    var ligandBox = Box<Ligand>()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if _scenePhase == .active && scnViewBox.value != nil {
                updateSelectionBind()
                    .frame(width: UIScreen.main.bounds.size.width,
                           height: UIScreen.main.bounds.height,
                           alignment: .center)
                    .zIndex(1)
                if showInfo {
                    if let node = scnViewBox.value.scenekitClass.selectedElement?.scnNode {
                        if let atom = allAtoms.value[node], let atomInfo = atomInfos[atom.element.uppercased()] {
                            AtomInfoView(atomInfo: atomInfo, atom: atom)
                            .padding(10)
                            .frame(width: UIScreen.main.bounds.size.width,
                                   height: UIScreen.main.bounds.height / 2,
                                   alignment: .top)
                            .zIndex(3)
                            .background(Color(UIColor.gray.withAlphaComponent(0.7)))
                            .cornerRadius(20, corners: .topLeft)
                            .cornerRadius(20, corners: .topRight)
                        }
                    }
                }
                else {
                    HStack {
                        Button(action: {
                            share(items: [scnViewBox.value.scenekitClass.view.snapshot(), ligandBox.value.name],
                                  excludedActivityTypes: [.postToFlickr])
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .padding(30)
                        } .zIndex(3)
                        Button(action: {
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
                            
                            scnViewBox.value.scenekitClass.scene.background.contents = colors.randomElement()
                        }) {
                            Image(systemName: "paintbrush")
                                .padding(30)
                        }
                    }.zIndex(2)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: UIScreen.main.bounds.size.width,
               height: UIScreen.main.bounds.height,
               alignment: .center)
        .onChange(of: _scenePhase) { phase in
            if phase == .background {
                lock()
            } else if phase == .active && scnViewBox.value == nil {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            print("opened \(ligandBox.value.name)  \(id)")
        }
        
    }
    
    init(atomInfos: [String: AtomInfo], logBox: Box<LoginView>, loginState: Model) {
        self.client = Configurator.getClient()
        self.atomInfos = atomInfos
        self.loginView = logBox
        self.loginableModel = loginState
    }
    
    
    func loadData(ligand: Ligand) {
        self.ligandBox.value = ligand
        let pdbDoc = client.gePdb(name: ligandBox.value.name)
        let box = Box(value: pdbDoc)
        let _ = recursiveCheck(doc: box)
        self.ligandBox.value.pdbDoc = box.value!
        scnViewBox.value = ScenekitView(scenekitClass: ScenekitClass(scene:  generate(scene: SCNScene()),
                                                                     isSelectedElement: _showInfo.projectedValue))
        print("\(id) updated")
    }
    
    func getValence(el: String) -> Int {
        let info = atomInfos[el.uppercased()]!
        if ["H", "F", "CL", "BR", "I", "AT", "TS"].contains(info.symbol)
            || info.catigory == "alkali metal" {
            return 1
        } else if info.symbol == "O" || info.catigory == "alkaline earth metal" {
            return 2
        } else if ["AL", "B", "N"].contains(info.symbol) {
            return 3
        } else if (info.symbol == "C") {
            return 4
        }
        return 1
    }
    
    func recursiveCheck(doc: Box<PdbDocument>, fromAtomNumber: Int? = nil, checkingAtomNumber: Int? = nil, visited: Box<[Int]>? = nil) -> Bool {
        if checkingAtomNumber == nil {
            for a in 0..<doc.value.atoms.count {
                let _ = recursiveCheck(doc: doc, checkingAtomNumber: a, visited: Box(value: [Int]()))
            }
            return true
        } else {
            let atomN = checkingAtomNumber!
            let atom = doc.value.atoms[atomN]
            let valence = getValence(el: atom.element)
            let connections = doc.value.connections.all{ x in x.second == atomN || x.first == atomN}
            if connections.count == valence {
                return true
            } else {
                var v = 0
                for c in connections {
                    v += c.isDouble ? 2 : 1
                }
                if v >= valence {
                    return true
                }
            }
            let atoms = connections.map{x in x.first == atomN ? doc.value.atoms[x.second] : doc.value.atoms[x.first]}
            let fromAtom = doc.value.atoms[fromAtomNumber ?? atomN]
            var falses = 0
            visited?.value.append(checkingAtomNumber!)
            for atom in atoms {
                if atom.number != fromAtom.number && !visited!.value!.contains(atom.number) {
                    if !recursiveCheck(doc: doc, fromAtomNumber: checkingAtomNumber, checkingAtomNumber: atom.number, visited: visited) {
                        falses += 1
                    }
                }
            }
            if falses == 0 {
                if fromAtomNumber != nil {
                    let index = doc.value.connections.firstIndex {x in (x.first == fromAtomNumber && x.second == checkingAtomNumber)
                        || (x.second == fromAtomNumber && x.first == checkingAtomNumber)}
                    doc.value.connections[index!].isDouble = true
                } else {
                    print("wtf?: \(checkingAtomNumber!)")
                    if connections.count == 1 {
                        let conn = connections.first
                        let index = doc.value.connections.firstIndex {x in conn?.first == x.first && conn?.second == x.second}
                        doc.value.connections[index!].isDouble = true
                    }
                }
                
            }
            let _ = visited?.value.removeLast()
            return false
        }
    }
    
    func generate(scene: SCNScene) -> SCNScene {
        let center = SCNNode()
        center.position = SCNVector3(x: 0, y: 0, z: 0)
        let constraint = SCNLookAtConstraint(target: center)
        constraint.isGimbalLockEnabled = true
        
        let rezCamera = SCNNode()
        let camera = SCNCamera()
        camera.zFar = 10000
        rezCamera.camera = camera
        rezCamera.position = SCNVector3(x: -20, y: 15, z: 20)
        rezCamera.constraints = [constraint]
        
        let ambientLight = SCNLight()
        ambientLight.color = UIColor.darkGray
        ambientLight.type = .ambient
        rezCamera.light = ambientLight
        
        let lightA = SCNNode()
        lightA.light = ambientLight
        
        let spotlight = SCNLight()
        spotlight.type = .spot
        spotlight.castsShadow = true
        spotlight.spotInnerAngle = 70.0
        spotlight.spotOuterAngle = 90.0
        spotlight.zFar = 500
        
        let light = SCNNode()
        light.light = spotlight
        light.position = SCNVector3(x: 0, y: 25, z: 25)
        light.constraints = [constraint]
        
        /*
         White for hydrogen
         Black for carbon
         Blue for nitrogen
         Red for oxygen
         Deep yellow for sulfur
         Purple for phosphorus
         Light, medium, medium dark, and dark green for the halogens (F, Cl, Br, I)
         Silver for metals (Co, Fe, Ni, Cu)
         
         
         */
        
        var spheres = [String: SCNSphere]()
        for name in ["O": UIColor.red,
                     "C": UIColor.black,
                     "N": UIColor.blue,
                     "H": UIColor.white,
                     "S": UIColor.yellow,
                     "BR": UIColor.brown,
                     "I": UIColor.purple,
                     "HE": UIColor.cyan,
                     "NE": UIColor.cyan,
                     "AR": UIColor.cyan,
                     "KR": UIColor.cyan,
                     "XE": UIColor.cyan,
                     "B": UIColor.orange,
                     "P": UIColor.orange,
                     "LI": UIColor.purple,
                     "NA": UIColor.purple,
                     "K": UIColor.purple,
                     "RB": UIColor.purple,
                     "CS": UIColor.purple,
                     "FR": UIColor.purple,
                     "F": UIColor.green,
                     "CI": UIColor.green,
                     "BE": UIColor.green,
                     "MG": UIColor.green,
                     "CA": UIColor.green,
                     "SR": UIColor.green,
                     "BA": UIColor.green,
                     "RA": UIColor.green,
                     "TI": UIColor.gray,
                     "FE": UIColor.orange,
                     "XXX": UIColor.systemPink] {
            spheres[name.key] = SCNSphere(radius: 0.35)
            let material = SCNMaterial()
            material.diffuse.contents = name.value.withAlphaComponent(0.85)
            material.lightingModel = .blinn
            material.transparencyMode = .dualLayer
            material.fresnelExponent = 1.5
            material.shininess = 50
            material.reflective.contents = 0.4
            spheres[name.key]!.materials = [material]
            
        }
        
        for x in ligandBox.value.pdbDoc!.atoms {
            let sphereG = spheres[x.element] ?? spheres["XXX"]!
            //print(sphereG)
            let sphere = SCNNode(geometry: sphereG)
            sphere.position = SCNVector3(x: Float(x.x),
                                         y: Float(x.y),
                                         z: Float(x.z))
            sphere.name = "\(x.number): \(x.name)"
            if x.element == "C" {
                let omniLight = SCNLight()
                omniLight.type = .omni
                omniLight.castsShadow = true
                omniLight.spotInnerAngle = 70.0
                omniLight.spotOuterAngle = 90.0
                omniLight.zFar = 500
                
                let light = SCNNode()
                light.light = omniLight
                light.position = sphere.position
                scene.rootNode.addChildNode(light)
            }
            scene.rootNode.addChildNode(sphere)
            allAtoms.value[sphere] = x
        }
        
        for x in ligandBox.value.pdbDoc!.connections {
            let a1 = ligandBox.value.pdbDoc!.atoms[x.first]
            let a2 = ligandBox.value.pdbDoc!.atoms[x.second]
            
            if !x.isDouble {
                var stick = SCNNode()
                stick = stick.buildLineInTwoPointsWithRotation(from: SCNVector3(x: Float(a1.x), y: Float(a1.y), z: Float(a1.z)),
                                                               to: SCNVector3(x: Float(a2.x), y: Float(a2.y), z: Float(a2.z)),
                                                               radius: 0.1,
                                                               color: UIColor.gray)
                stick.name = "\(x.first) - \(x.second)"
                scene.rootNode.addChildNode(stick)
            } else {
                let radius = Float(0.05)
                var stick1 = SCNNode()
                stick1 = stick1.buildLineInTwoPointsWithRotation(from: SCNVector3(x: Float(a1.x) + radius,
                                                                                  y: Float(a1.y) + radius,
                                                                                  z: Float(a1.z) + radius),
                                                                 to: SCNVector3(x: Float(a2.x) + radius, y: Float(a2.y) + radius,
                                                                                z: Float(a2.z) + radius),
                                                                 radius: CGFloat(radius),
                                                                 color: UIColor.gray)
                stick1.name = "1: \(x.first) - \(x.second)"
                scene.rootNode.addChildNode(stick1)
                
                var stick2 = SCNNode()
                stick2 = stick2.buildLineInTwoPointsWithRotation(from: SCNVector3(x: Float(a1.x) - radius,
                                                                                  y: Float(a1.y) - radius,
                                                                                  z: Float(a1.z) - radius),
                                                                 to: SCNVector3(x: Float(a2.x) - radius,
                                                                                y: Float(a2.y) - radius,
                                                                                z: Float(a2.z) - radius),
                                                                 radius: CGFloat(radius),
                                                                 color: UIColor.gray)
                stick2.name = "2: \(x.first) - \(x.second)"
                scene.rootNode.addChildNode(stick2)
            }
            
        }
        
        scene.rootNode.addChildNode(lightA)
        scene.background.contents = UIColor.white
        return scene
    }
    
    @discardableResult
    func share(
        items: [Any],
        excludedActivityTypes: [UIActivity.ActivityType]? = nil
    ) -> Bool {
        
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

