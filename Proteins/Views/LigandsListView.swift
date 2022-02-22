//
//  ContentView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 09.01.2022.
//

import SwiftUI

struct LigandsListView: BaseView {
    var loginableModel: Model
    
    var loginView: Box<LoginView>
    
    
    @Environment(\.scenePhase) var _scenePhase
    
    
    @ObservedObject var ligands: Ligands
    @State var searchText: String = ""
    @State private var scale: CGFloat = 0.1
    @State private var showingDetail = false
    @State private var ligandView: LigandView!
    @State private var isLoading = false
    private let atomInfos: [String: AtomInfo]
    private let lv: LigandView
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView()
                        .zIndex(3)
                }
                VStack {
                    NavigationLink(isActive: $showingDetail, destination: {lv})
                    {
                        EmptyView()
                    }
                    TextField("Search...", text: $searchText)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    List {
                        ForEach(ligands.items.filter{searchText.isEmpty || $0.name.contains(searchText)}, id: \.id) { ligand in
                            Text(ligand.name)
                                .font(.headline)
                                .padding(5)
                                .onTapGesture{
                                    self.isLoading = true
                                    lv.loadData(ligand: ligand)
                                    self.showingDetail = true
                                    self.isLoading = false
                                }
                                .onAppear {
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
                .zIndex(1)
            }
        }
        .onChange(of: _scenePhase) { phase in
            if phase == .background {
                lock()
            }
        }
    }
    
    init(ligands: Ligands, atoms: [String: AtomInfo], logView: Box<LoginView>, loginState: Model) {
        self.ligands = ligands
        self.atomInfos = atoms
        self.loginView = logView
        self.loginableModel = loginState
        self.lv = LigandView(atomInfos: atomInfos, logBox: loginView, loginState: loginableModel)
    }
}