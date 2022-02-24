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
            Configurator.getLoginView()
        }
    }
    
    init() {
        
        Configurator.configure()
        UITableView.appearance().backgroundColor = .clear
    }

}
