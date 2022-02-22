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
            scnViewBox.value.updateSelectionBind(isSelectedElement: $showInfo, selectedElement: $selectedElement)
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
        recursiveCheck(doc: box)
        self.ligandBox.value.pdbDoc = box.value!
        scnViewBox.value = ScenekitView(scenekitClass: ScenekitClass(scene:  generate(scene: SCNScene()),
                                                                     isSelectedElement: $showInfo,
                                                                     selectedElement: $selectedElement))
        print("\(id) updated")
    }
    
    /*
         одновалентны водород, галогены, щелочные металлы (alkali metal) К галогенам относятся фтор F, хлор Cl, бром Br, иод I, астат At, а также (формально) искусственный элемент теннессин Ts
         двухвалентны кислород, щелочноземельные металлы. alkaline earth metal
         трехвалентны алюминий (Al) и бор (B).
     */
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
                let index = doc.value.connections.firstIndex {x in (x.first == fromAtomNumber && x.second == checkingAtomNumber)
                                                || (x.second == fromAtomNumber && x.first == checkingAtomNumber)}
                doc.value.connections[index!].isDouble = true
            }
            let _ = visited?.value.removeLast()
            return false
        }
    }
    
    func checkValence(doc: Box<PdbDocument>) -> PdbDocument {
        for i in  0..<doc.value.connections.count {
            let conn = doc.value.connections[i]
            let atom1 = doc.value.atoms[conn.first]
            let atom2 = doc.value.atoms[conn.second]
            let v1 = getValence(el: atom1.element)
            let v2 = getValence(el: atom2.element)
            
            if v1 == 1 || v2 == 1 {
                continue
            }
            
            var countV1 = 0
            var countV2 = 0
            
            for connection in  doc.value.connections {
                if ((conn.first == connection.first) && (conn.second != connection.second)) ||
                    ((conn.first == connection.second) && (conn.second != connection.first)) {
                    countV1 += connection.isDouble ? 2 : 1
                } else if ((conn.second == connection.second) && (conn.first != connection.first)) ||
                            ((conn.second == connection.first) && (conn.first != connection.second)) {
                    countV2 += connection.isDouble ? 2 : 1
                }
            }
            
            if countV1 + 1 < v1 && countV2 + 1 < v2 {
                doc.value.connections[i].isDouble = true
            }
        }
        return doc.value
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

