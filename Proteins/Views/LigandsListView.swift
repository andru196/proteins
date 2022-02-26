//
//  ContentView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 09.01.2022.
//

import SwiftUI

struct LigandsListView: BaseView {
    var loginView: Box<LoginView>
    private var lv: LigandView = Configurator.getLigandView()
    
    @Environment(\.scenePhase) var _scenePhase
    @ObservedObject var viewModel: Ligands
    

    @State private var scale: CGFloat = 0.1
    @State private var ligandView: LigandView!
    @State private var rotation = 0.1
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    VStack {
                        Text("42")
                            .font(.largeTitle)
                            .padding(10)
                            .rotation3DEffect(.degrees(rotation), axis: (x: CGFloat.random(in: -1...1),
                                                                         y: CGFloat.random(in: -1...1),
                                                                         z: CGFloat.random(in: -1...1)))
                            .onAppear {
                                self.rotation = 0
                                let baseAnimation = Animation.linear(duration: 0.7)
                                let repeated = baseAnimation.repeatForever(autoreverses: false)
                                return withAnimation(repeated) {
                                    self.rotation = 360
                                }
                            }
                        Text("Loading...")
                    }
                    .zIndex(3)
                    .padding(15)
                    .background(Color(UIColor.lightGray.withAlphaComponent(0.3)))
                    .cornerRadius(20, corners: .bottomRight)
                    .cornerRadius(20, corners: .topLeft)
                    .onAppear {
                        viewModel.onAppearLoading(loader: lv.viewModel.loadData)
                        
                    }
                }
                VStack {
                    NavigationLink(isActive: $viewModel.showingDetail, destination: {lv})
                    {
                        EmptyView()
                    }
                    TextField("Search...", text: $viewModel.searchText)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    List {
                        ForEach(viewModel.searchedItems, id: \.id) { ligand in
                            HStack {
                                Text(ligand.name)
                                .font(.headline)
                            }
                                .padding(5)
                                .onTapGesture {
                                    self.viewModel.selectLigand(ligand)
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
                .blur(radius: viewModel.isLoading ? 10 : 0)
                .hasScrollEnabled(!viewModel.isLoading)
            }
            .alert(isPresented: $viewModel.loadedUnsuccess) {
                Alert(title: Text("Error"),
                      message: Text("Can't load data"),
                      dismissButton: .default(Text("OK")))
            }
        }
        .onChange(of: _scenePhase) { phase in
            if phase == .background {//|| phase == .inactive {
                lock()
            }
        }
    }
    
    init(ligands: Ligands, logView: Box<LoginView>) {
        self.viewModel = ligands
        self.loginView = logView
    }
}
