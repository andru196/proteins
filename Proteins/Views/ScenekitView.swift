//
//  ScenekitView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 16.02.2022.
//

import SwiftUI
import SceneKit


struct ScenekitView : UIViewRepresentable {
    let scenekitClass: ScenekitClass
    
    func makeUIView(context: Context) -> SCNView {
        print("View make")
        return scenekitClass.view
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        print("View Updeted")
    }
}

class ScenekitClass {
    let view = SCNView()
    let scene: SCNScene
    
    @ObservedObject var viewModel : LigandViewViewMode
    
    init(scene: SCNScene, viewModel: LigandViewViewMode) {
        self.scene = scene
        self.viewModel = viewModel
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        // attach the scene
        view.scene = scene
        // allows the user to manipulate the camera
        view.allowsCameraControl = true
        // configure the view
        view.backgroundColor = UIColor.black
        // add a tap gesture recognizer
        let tg = ScenekitClass.makeRecigizer(self)
        view.addGestureRecognizer(tg)
    }
    
    static func makeRecigizer(_ element: ScenekitClass) -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: element, action: #selector(handleTap(_:)))
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: view)
        let hitResults = view.hitTest(p, options: [:])
        self.viewModel.unselected()
        if hitResults.count > 0 {
            
            let result = hitResults[0]

            self.viewModel.selected(selectedElement: result.node)
            let material = result.node.geometry!.firstMaterial
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5

            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material?.emission.contents = UIColor.black
                SCNTransaction.commit()
            }
            material?.emission.contents = UIColor.green
            SCNTransaction.commit()
            
        }
        else {
            self.viewModel.unselected()
        }
    }
}

struct Node {
    let scnNode: SCNNode
}
