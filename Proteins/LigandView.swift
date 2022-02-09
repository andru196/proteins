//
//  LigandView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 10.02.2022.
//

import SwiftUI
import SceneKit

struct LigandView: View {
    @State var scene = SCNScene()
    @State var ligand: Ligand!
    
    var body: some View {
        SceneView(scene: scene, options: [.allowsCameraControl, .autoenablesDefaultLighting])
            .frame(width: .infinity, height: .infinity)
            .border(Color.green, width: 5)
            .edgesIgnoringSafeArea(.all)
    }
    
    init(ligand: Ligand) {
        self.ligand = ligand
    }
}

struct LigandView_Previews: PreviewProvider {
    static var previews: some View {
        LigandView(ligand: Ligand(name: "this"))
    }
}
