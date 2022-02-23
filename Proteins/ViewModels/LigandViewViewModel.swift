//
//  LigandViewViewModel.swift
//  Proteins
//
//  Created by Andrew Tarasow on 23.02.2022.
//

import SwiftUI
import SceneKit

final class LigandViewViewMode: ObservableObject {
    @Published private(set) var isSelectedElement: Bool = false
    private(set) var selectedElement: SCNNode?
    
    func selected(selectedElement: SCNNode?) {
        isSelectedElement = true
        self.selectedElement = selectedElement
    }
    
    func unselected() {
        isSelectedElement = false
        self.selectedElement = nil
    }
}
