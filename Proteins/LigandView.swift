//
//  LigandView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 10.02.2022.
//

import SwiftUI
import SceneKit

struct LigandView: View {
    var scene: SCNScene!
    @State var ligand: Ligand!
    
    var camera: SCNNode!
    var ground: SCNNode!
    var light: SCNNode!
    var button: SCNNode!
    var sphere1: SCNNode!
    var sphere2: SCNNode!
    
    var body: some View {
        SceneView(scene: self.scene,
                  options: [.allowsCameraControl, .autoenablesDefaultLighting]
        )
            .border(Color.blue, width: 5)
            .edgesIgnoringSafeArea(.all)
    }
    
    init(ligand: Ligand) {
        let scene = generate()
        self.scene = scene
        self.ligand = ligand
    }
    
    mutating func generate() -> SCNScene {
        let scene = SCNScene()
        
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0.02
        
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.blue
        groundGeometry.materials = [groundMaterial]
        ground = SCNNode(geometry: groundGeometry)
        
        let constraint = SCNLookAtConstraint(target: ground)
        constraint.isGimbalLockEnabled = true
        
        let camera = SCNCamera()
        camera.zFar = 10000
        self.camera =  SCNNode()
        self.camera.camera = camera
        self.camera.position = SCNVector3(x: -20, y: 15, z: 20)
        self.camera.constraints = [constraint]
      
        let ambientLight = SCNLight()
        ambientLight.color = UIColor.darkGray
        ambientLight.type = .ambient
        self.camera.light = ambientLight
        
        let spotlight = SCNLight()
        spotlight.type = .spot
        spotlight.castsShadow = true
        spotlight.spotInnerAngle = 70.0
        spotlight.spotOuterAngle = 90.0
        spotlight.zFar = 500
        
        light = SCNNode()
        light.light = spotlight
        light.position = SCNVector3(x: 0, y: 25, z: 25)
        light.constraints = [constraint]
        
        let sphereGeometry = SCNSphere(radius: 1.5)
        let sphereMateral = SCNMaterial()
        sphereMateral.diffuse.contents = UIColor.green
        sphereGeometry.materials = [sphereMateral]

        sphere1 = SCNNode(geometry: sphereGeometry)
        sphere1.position = SCNVector3(x: -15, y: 1.5, z: 0)
        
        sphere2 = SCNNode(geometry: sphereGeometry)
        sphere2.position = SCNVector3(x: 15, y: 1.5, z: 0)
        
        let buttonGeometry = SCNBox(width: 4, height: 1, length: 4, chamferRadius: 0)
        let buttonMaterial = SCNMaterial()
        buttonMaterial.diffuse.contents = UIColor.red
        buttonGeometry.materials = [buttonMaterial]
        button = SCNNode(geometry: buttonGeometry)
        button.position = SCNVector3(x: 0, y: 0.5, z: 15)
        
        // Physic
        let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
        let groundBody = SCNPhysicsBody(type: .kinematic, shape: groundShape)
        groundBody.contactTestBitMask = 0
        ground.physicsBody = groundBody
        
        let gravitField = SCNPhysicsField.radialGravity()
        gravitField.strength = 0
        sphere1.physicsField = gravitField
        
        let shape = SCNPhysicsShape(geometry: sphereGeometry, options: nil)
        let sphere1Body = SCNPhysicsBody(type: .kinematic, shape: shape)
        sphere1Body.contactTestBitMask = 1
        sphere1.physicsBody = sphere1Body
        let sphere2Body = SCNPhysicsBody(type: .dynamic, shape: shape)
        sphere2.physicsBody = sphere2Body
        sphere2Body.contactTestBitMask = 1
        
        
        let constraint1 = SCNLookAtConstraint(target: sphere1)
        constraint1.isGimbalLockEnabled = true
        self.camera.constraints = [constraint1]
        
        scene.rootNode.addChildNode(ground)
        scene.rootNode.addChildNode(light)
        scene.rootNode.addChildNode(button)
        scene.rootNode.addChildNode(sphere1)
        scene.rootNode.addChildNode(sphere2)
        scene.rootNode.addChildNode(self.camera)
        return scene
    }
}


struct LigandView_Previews: PreviewProvider {
    static var previews: some View {
        LigandView(ligand: Ligand(name: "this"))
    }
}
