//
//  LigandView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 10.02.2022.
// http://files.rcsb.org/ligands/view/\(filteredNames[index])_ideal.pdb

import SwiftUI
import SceneKit

struct LigandView: View {
    
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
                    .padding(25)
            } .zIndex(3)
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
                            Text(atom.name)
                            Text(atom.element)
                            Text(atomInfo.summary)
                        }
                        .frame(width: UIScreen.main.bounds.size.width,
                               height: UIScreen.main.bounds.height / 2,
                               alignment: .top)
                        .zIndex(2)
                        .background(Color(UIColor.gray.withAlphaComponent(0.7)))
                        .addBorder(Color.black, width: 1, cornerRadius: 20)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: UIScreen.main.bounds.size.width,
               height: UIScreen.main.bounds.height,
               alignment: .center)
        
    }
    
    init(ligand: Ligand, atomInfos: [String: AtomInfo]) {
        self.ligand = ligand
        self.client = Configurator.getClient()
        self.atomInfos = atomInfos
        if self.ligand.pdbDoc == nil {
            self.ligand.pdbDoc = client.getPdb(name: ligand.name)
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
    
}


struct LigandView_Previews: PreviewProvider {
    static var previews: some View {
        LigandView(ligand: Ligand(name: "this"), atomInfos: [String : AtomInfo]())
    }
}



extension SCNVector3 {
    
    /// Calculate the magnitude of this vector
    var magnitude:SCNFloat {
        get {
            return sqrt(dotProduct(self))
        }
    }
    
    /// Vector in the same direction as this vector with a magnitude of 1
    var normalized:SCNVector3 {
        get {
            let localMagnitude = magnitude
            let localX = x / localMagnitude
            let localY = y / localMagnitude
            let localZ = z / localMagnitude
            
            return SCNVector3(localX, localY, localZ)
        }
    }
    
    /**
     Calculate the dot product of two vectors
     
     - parameter vectorB: Other vector in the calculation
     */
    func dotProduct(_ vectorB:SCNVector3) -> SCNFloat {
        
        return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
    }
    
    /**
     Calculate the dot product of two vectors
     
     - parameter vectorB: Other vector in the calculation
     */
    func crossProduct(_ vectorB:SCNVector3) -> SCNVector3 {
        
        let computedX = (y * vectorB.z) - (z * vectorB.y)
        let computedY = (z * vectorB.x) - (x * vectorB.z)
        let computedZ = (x * vectorB.y) - (y * vectorB.x)
        
        return SCNVector3(computedX, computedY, computedZ)
    }
    
    /**
     Calculate the angle between two vectors
     
     - parameter vectorB: Other vector in the calculation
     */
    func angleBetweenVectors(_ vectorB:SCNVector3) -> SCNFloat {
        
        //cos(angle) = (A.B)/(|A||B|)
        let cosineAngle = (dotProduct(vectorB) / (magnitude * vectorB.magnitude))
        return SCNFloat(acos(cosineAngle))
    }
}

extension SCNNode {
    
    func buildLineInTwoPointsWithRotation(from startPoint: SCNVector3,
                                          to endPoint: SCNVector3,
                                          radius: CGFloat,
                                          color: UIColor) -> SCNNode {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
        
        if l == 0.0 {
            // two points together.
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            self.geometry = sphere
            self.position = startPoint
            return self
            
        }
        
        let cyl = SCNCylinder(radius: radius, height: l)
        cyl.firstMaterial?.diffuse.contents = color
        
        self.geometry = cyl
        
        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0,0)
        //target vector, in new coordination
        let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                            (endPoint.z-startPoint.z)/2.0)
        
        // axis between two vector
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
        
        //normalized axis vector
        let av_normalized = av.normalized
        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0
        
        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0
        
        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0
        
        self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
        self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
        self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
        self.transform.m44 = 1.0
        return self
    }
}

protocol HasApply { }

extension HasApply {
    func apply(closure:(Self) -> ()) -> Self {
        closure(self)
        return self
    }
}

extension SCNSphere: HasApply { }
extension SCNMaterial: HasApply { }

extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
            .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}
