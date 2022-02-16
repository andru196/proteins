//
//  ScenekitView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 16.02.2022.
//

import Foundation

import SwiftUI
import SceneKit


struct ScenekitView : UIViewRepresentable {
    let scenekitClass: ScenekitClass

    func makeUIView(context: Context) -> SCNView {
        return scenekitClass.view
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        // your update UI view contents look like they can all be done in the initial creation
    }
}

class ScenekitClass {
    let view = SCNView()
    let scene: SCNScene
    
    init(scene: SCNScene) {
        self.scene = scene
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

        // show statistics such as fps and timing information
        view.showsStatistics = true

        // configure the view
        view.backgroundColor = UIColor.black

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: view)
        let hitResults = view.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]

            print(result.node.name)
            // get material for selected geometry element
            let material = result.node.geometry!.firstMaterial
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5

            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5

                material?.emission.contents = UIColor.black

                SCNTransaction.commit()
            }

            material?.emission.contents = UIColor.green

            SCNTransaction.commit()
        }
    }
}

#if DEBUG
struct ScenekitView_Previews : PreviewProvider {
    static var previews: some View {
        ScenekitView(scenekitClass: ScenekitClass(scene: SCNScene()))
    }
}
#endif
