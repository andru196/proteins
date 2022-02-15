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
    
    @State var scene = SCNScene()
    var ligand: Ligand!
    
//    var camera: SCNNode!
//    var ground: SCNNode!
//    var light: SCNNode!
//    var button: SCNNode!
//    var sphere1: SCNNode!
//    var sphere2: SCNNode!
    
    var body: some View {
        SceneView(scene: generate(scene: scene),
                  options: [.allowsCameraControl, .autoenablesDefaultLighting]
        )
            .border(Color.pink, width: 5)
            .edgesIgnoringSafeArea(.all)
    }
    
    init(ligand: Ligand) {
        self.ligand = ligand
        self.client = Configurator.getClient()
        if self.ligand.pdbDoc == nil {
            self.ligand.pdbDoc = client.getPdb(name: ligand.name)
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
//        let ambientLight = SCNLight()
//        ambientLight.color = UIColor.darkGray
//        ambientLight.type = .ambient
//        rezCamera.light = ambientLight
        
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
        
        let sphereG = SCNSphere(radius: 0.5)
        let sphereM = SCNMaterial()
        sphereM.diffuse.contents = UIColor.red
        sphereG.materials = [sphereM]
        for x in ligand.pdbDoc!.atoms {
            let sphere = SCNNode(geometry: sphereG)
            sphere.position = SCNVector3(x: Float(x.x),
                                         y: Float(x.y),
                                         z: Float(x.z))
            scene.rootNode.addChildNode(sphere)
        }
        
        let stickM = SCNMaterial()
        stickM.diffuse.contents = UIColor.blue
        for x in ligand.pdbDoc!.connections {
            let a1 = ligand.pdbDoc!.atoms[x.first]
            let a2 = ligand.pdbDoc!.atoms[x.second]
            
            let stickG = SCNCylinder(radius: 0.1, height:
                                        sqrt( (a1.x - a2.x) * (a1.x - a2.x)
                                              + (a1.y - a2.y) * (a1.y - a2.y)
                                              + (a1.z - a2.z) * (a1.z - a2.z)
                ))
            stickG.materials = [stickM]
            
            let stick = SCNNode(geometry: stickG)
            stick.position = SCNVector3(x: Float((a1.x + a2.x) / 2),
                                        y: Float((a1.y + a2.y) / 2),
                                        z: Float((a1.z + a2.z) / 2))
            scene.rootNode.addChildNode(stick)
            
        }
  
        
        scene.rootNode.addChildNode(light)
        scene.rootNode.addChildNode(rezCamera)
        return scene
    }
}


struct LigandView_Previews: PreviewProvider {
    static var previews: some View {
        LigandView(ligand: Ligand(name: "this"))
    }
}
