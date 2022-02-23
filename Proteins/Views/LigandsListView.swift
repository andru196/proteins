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
    @State private var isLoading = false {
        didSet {
            if isLoading == false && oldValue {
                self.showingDetail = true
                
            }
        }
    }
    @State private var selectedLigand: Ligand!
    private let atomInfos: [String: AtomInfo]
    private let lv: LigandView
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Loading...")
                    }
                    .zIndex(3)
                    .padding(15)
                    .background(Color(UIColor.lightGray.withAlphaComponent(0.3)))
                    .cornerRadius(20, corners: .bottomRight)
                    .cornerRadius(20, corners: .topLeft)
                    .onAppear {
                        if isLoading && selectedLigand != nil {
                            DispatchQueue.main.async {
                                lv.loadData(ligand: selectedLigand)
                                isLoading = false
                            }
                        }
                    }
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
                                    selectedLigand = ligand
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
                .zIndex(1)
                .blur(radius: isLoading ? 10 : 0)
                .hasScrollEnabled(!isLoading)
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
