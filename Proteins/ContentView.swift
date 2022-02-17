//
//  ContentView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 09.01.2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var ligands: Ligands
    @State var searchText: String = ""
    @State private var scale: CGFloat = 0.1
    private let atomInfos: [String: AtomInfo]
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search...", text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                List {
                    ForEach(ligands.items.filter{searchText.isEmpty || $0.name.contains(searchText)}, id: \.id) { ligand in
                        NavigationLink(destination: LigandView(ligand: ligand, atomInfos: atomInfos)) {
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
            }
        }
    }
    
    init(ligands: Ligands, atoms: [String: AtomInfo]) {
        self.ligands = ligands
        self.atomInfos = atoms
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(ligands: Ligands(names: ["hz", "hz2"]), atoms: [String: AtomInfo]())
    }
}
