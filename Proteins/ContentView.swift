//
//  ContentView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 09.01.2022.
//

import SwiftUI

struct ContentView: BaseView {
    var loginableModel: Model
    
    var loginView: Box<LoginView>
    
    
    @Environment(\.scenePhase) var _scenePhase
    
    
    @ObservedObject var ligands: Ligands
    @State var searchText: String = ""
    @State private var scale: CGFloat = 0.1
    
    @State private var action: UUID? = nil
    
    
    private let atomInfos: [String: AtomInfo]
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search...", text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                List {
                    ForEach(ligands.items.filter{searchText.isEmpty || $0.name.contains(searchText)}, id: \.id) { ligand in
                        NavigationLink(destination: LigandView(ligand: ligand, atomInfos: atomInfos, logBox: loginView, loginState: loginableModel)) {
                            HStack {
                                Text(ligand.name)
                                    .font(.headline)
                            }
                        }
                    }
                    .navigationTitle("Select Ligand")
                    .scaleEffect(scale)
                    .onAppear{
                        withAnimation(Animation.easeOut(duration: 0.8)) {
                            self.scale = 1
                        }
                    }
                }
                .background(Color.init(uiColor: UIColor.gray.withAlphaComponent(0.25)))
            }
        }.onChange(of: _scenePhase) { _ in
            loginableModel.lock = true
            lock()
        }
    }
    
    init(ligands: Ligands, atoms: [String: AtomInfo], logView: Box<LoginView>, loginState: Model) {
        self.ligands = ligands
        self.atomInfos = atoms
        self.loginView = logView
        self.loginableModel = loginState
    }
}
