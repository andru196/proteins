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
    
    var scenePhase: ScenePhase! {
        didSet {
            lock()
        }
    }
    
    @Environment(\.scenePhase) var _scenePhase {
        
        didSet {
            lock()
         //   self.scenePhase = _scenePhase
        }
    }
    
    var loginView: Box<LoginView>
    
    
    var client: PdbClient!
    
    @State var showInfo: Bool = false
    @State var scene = SCNScene()
    @State var selectedElement: Node? = nil {
        mutating didSet {
            if let atom = selectedElement?.scnNode {
                selectedAtom = allAtoms[atom]
            }
        }
    }
    var selectedAtom: PDBAtom?
    var allAtoms = [SCNNode: PDBAtom]()
    var _scnView: ScenekitView!
    private let atomInfos: [String: AtomInfo]
    
    mutating func getSceneView() -> ScenekitView {
        if _scnView == nil {
            _scnView = (ScenekitView(scenekitClass: ScenekitClass(scene:  generate(scene: scene),
                                                                  isSelectedElement: $showInfo,
                                                                  selectedElement: $selectedElement)))
        }
        return _scnView
    }
    
    func updateSelectionBind() -> ScenekitView {
        _scnView.updateSelectionBind(isSelectedElement: $showInfo, selectedElement: $selectedElement)
        return _scnView
    }
    
    var ligand: Ligand!
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            updateSelectionBind()
                .frame(width: UIScreen.main.bounds.size.width,
                       height: UIScreen.main.bounds.height,
                       alignment: .center)
                .zIndex(1)
            if showInfo {
                if let node = _scnView.scenekitClass.selectedElement?.scnNode {
                    if let atom = allAtoms[node], let atomInfo = atomInfos[atom.element] {
                        VStack
                        {
                            Text(atomInfo.name)
                                .font(.largeTitle)
                            HStack{
                                Text(atom.element).fontWeight(.bold)
                                Text(atom.name)
                                Link("Wikipedia", destination: URL(string: atomInfo.source)!)
                                    .padding(.leading, 10)
                            }
                            
                            if let dic: KeyValuePairs<String, String> =
                                ["Summary": atomInfo.summary,
                                 "Appearance": atomInfo.appearance ?? "NULL",
                                 "Atomic Mass": String(atomInfo.atomicMass) ,
                                 "Boil": String(atomInfo.boil ?? -1) ,
                                 "Category": atomInfo.catigory ?? "NULL",
                                 "Density": String(atomInfo.density ?? -1),
                                 "Discover By": atomInfo.discoverVy ?? "NULL",
                                 "Melt": String(atomInfo.melt ?? -1) ,
                                 "Molar Heat": String(atomInfo.molarHeat ?? -1) ,
                                 "Named By": atomInfo.namedBy ?? "NULL",
                                 "Number": String(atomInfo.number) ,
                                 "Period": String(atomInfo.period) ,
                                 "Phase": atomInfo.phase ,
                                 "X Posistion": String(atomInfo.xpos) ,
                                 "Y Position": String(atomInfo.ypos) ,
                                 "Shells": " ".join(elements: atomInfo.shells.map{String($0)}),
                                 "Electron Configuration": atomInfo.electronConfiguration ,
                                 "Electron Configuration Semantic": atomInfo.electronConfigurationSemantic ,
                                 "Electron Affinity": String(atomInfo.electronAffinity ?? -1) ,
                                 "Electronegativity Pauling": String(atomInfo.electronegativityPauling ?? -1) ,
                                 "Ionization Energies": " ".join(elements: atomInfo.ionizationEnergies.map{String($0)}),
                                 "CPK Hex": atomInfo.cpkHex ?? "NULL"
                                ] {
                                List {
                                    ForEach (dic, id: \.key) { kv in
                                        Section(header:Text(kv.key)){
                                            Text(kv.value)
                                                .onTapGesture(count: 2) {
                                                    UIPasteboard.general.string = kv.value
                                                }
                                        }
                                        .listRowBackground(Color.clear)
                                        
                                    }
                                }.listStyle(GroupedListStyle())
                                    .background(Color.clear)
                            }
                            
                        }
                        .padding(10)
                        .frame(width: UIScreen.main.bounds.size.width,
                               height: UIScreen.main.bounds.height / 2,
                               alignment: .top)
                        .zIndex(3)
                        .background(Color(UIColor.gray.withAlphaComponent(0.7)))
                        .addBorder(Color.black, width: 1, cornerRadius: 20)
                    }
                }
            }
            else {
                HStack {
                    Button(action: {
                        share(items: [_scnView.scenekitClass.view.snapshot(), ligand.name],
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
                        
                        scene.background.contents = colors.randomElement()
                    }) {
                        Image(systemName: "paintbrush")
                            .padding(30)
                    }
                }.zIndex(2)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: UIScreen.main.bounds.size.width,
               height: UIScreen.main.bounds.height,
               alignment: .center)
        .onChange(of: _scenePhase) { _ in
            loginableModel.lock = true
            lock()
        }
        
    }
    
    init(ligand: Ligand, atomInfos: [String: AtomInfo], logBox: Box<LoginView>, loginState: Model) {
        self.ligand = ligand
        self.client = Configurator.getClient()
        self.atomInfos = atomInfos
        self.loginView = logBox
        self.loginableModel = loginState
        if self.ligand.pdbDoc == nil {
            self.ligand.pdbDoc = client.gePdb(name: ligand.name)
        }
        getSceneView()
    }
    
    mutating func generate(scene: SCNScene) -> SCNScene {
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
                     "P": UIColor.purple,
                     "XXX": UIColor.magenta] {
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
        
        for x in ligand.pdbDoc!.atoms {
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
            allAtoms[sphere] = x
        }
        
        for x in ligand.pdbDoc!.connections {
            let a1 = ligand.pdbDoc!.atoms[x.first]
            let a2 = ligand.pdbDoc!.atoms[x.second]
            var stick = SCNNode()
            //            stick.position = SCNVector3(x: Float((a1.x + a2.x) / 2),
            //                                        y: Float((a1.y + a2.y) / 2),
            //                                        z: Float((a1.z + a2.z) / 2))
            
            stick = stick.buildLineInTwoPointsWithRotation(from: SCNVector3(x: Float(a1.x), y: Float(a1.y), z: Float(a1.z)),
                                                           to: SCNVector3(x: Float(a2.x), y: Float(a2.y), z: Float(a2.z)),
                                                           radius: 0.1,
                                                           color: UIColor.gray)
            stick.name = "\(x.first) - \(x.second)"
            scene.rootNode.addChildNode(stick)
            
        }
        
        scene.rootNode.addChildNode(lightA)
        //scene.rootNode.addChildNode(light)
        //        scene.rootNode.addChildNode(rezCamera)
        scene.background.contents = UIColor.white
        return scene
    }
    
    @discardableResult
    func share(
        items: [Any],
        excludedActivityTypes: [UIActivity.ActivityType]? = nil
    ) -> Bool {
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
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

