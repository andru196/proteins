//
//  ProteinsApp.swift
//  Proteins
//
//  Created by Andrew Tarasow on 09.01.2022.
//

import SwiftUI

@main
struct ProteinsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(ligands: Ligands(names: readLigandsList()))
        }
    }
    
    init() {
        
    }
    func readLigandsList() -> [String] {
        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let text = try String(contentsOfFile: path, encoding: .utf8)
                let ligands = text.split(separator: "\n")
                return ligands.map({
                    String($0)
                })
            } catch _ {
                //TODO: some error msg
                exit(1)
            }
        }
        return []
    }
}
