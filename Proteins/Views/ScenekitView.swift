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
    
    func updateSelectionBind(isSelectedElement: Binding<Bool>) {
        scenekitClass.updateSelectionBind(isSelectedElement: isSelectedElement)
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
    
    var selectedElement: Node? {
        didSet {
            if let se = selectedElement {
                print("Selected \(se)")
            } else {
                print("Selected empty")
            }
        }
    }
    
    init(scene: SCNScene, isSelectedElement: Binding<Bool>? = nil) {
        self.scene = scene
        self._isElementSelected = isSelectedElement!
        
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
    
    func updateSelectionBind(isSelectedElement: Binding<Bool>) {
        self._isElementSelected = isSelectedElement
    }
    
    static func makeRecigizer(_ element: ScenekitClass) -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: element, action: #selector(handleTap(_:)))
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: view)
        let hitResults = view.hitTest(p, options: [:])
        self.isElementSelected = false
        if hitResults.count > 0 {
            self.isElementSelected = true
            let result = hitResults[0]

            self.selectedElement = Node(scnNode: result.node)
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
