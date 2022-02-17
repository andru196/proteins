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
        print("View make")
        return scenekitClass.view
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        print("View Updeted")
        //scnView.addGestureRecognizer(ScenekitClass.makeRecigizer(scenekitClass))
        // your update UI view contents look like they can all be done in the initial creation
    }
    
    func updateSelectionBind(isSelectedElement: Binding<Bool>, selectedElement: Binding<Node?>) {
        scenekitClass.updateSelectionBind(isSelectedElement: isSelectedElement, selectedElement: selectedElement)
    }
}

class ScenekitClass {
    let view = SCNView()
    let scene: SCNScene
    @Binding var isElementSelected: Bool {
        didSet {
            print(oldValue, isElementSelected)
        }
    }
    
    @Binding var selectedElement: Node? {
        didSet {
            print(selectedElement)
        }
    }
    
    init(scene: SCNScene, isSelectedElement: Binding<Bool>? = nil,
         selectedElement: Binding<Node?>? = nil) {
        self.scene = scene
        self._isElementSelected = isSelectedElement!
        self._selectedElement = selectedElement!
        
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
    
    func updateSelectionBind(isSelectedElement: Binding<Bool>, selectedElement: Binding<Node?>) {
        self._isElementSelected = isSelectedElement
        self._selectedElement = selectedElement
    }
    
    static func makeRecigizer(_ element: ScenekitClass) -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: element, action: #selector(handleTap(_:)))
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: view)
        let hitResults = view.hitTest(p, options: [:])
        // check that we clicked on at least one object
        
        if hitResults.count > 0 {
            self.isElementSelected = true
            // retrieved the first clicked object
            let result = hitResults[0]

            print(result.node.name)
            self.selectedElement = Node(scnNode: result.node)
            self._selectedElement.update()
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
        else {
            self.isElementSelected = false
            self.selectedElement = nil
        }
    }
}

struct Node {
    let scnNode: SCNNode
}

#if DEBUG
struct ScenekitView_Previews : PreviewProvider {
    @State var stt: Bool = false
    static var previews: some View {
        ScenekitView(scenekitClass: ScenekitClass(scene: SCNScene()))
    }
}
#endif
