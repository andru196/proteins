//
//  LigandView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 10.02.2022.
//

import SwiftUI
import SceneKit

struct LigandView: BaseView {
    let id = UUID()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var viewModel : LigandViewViewMode
    var loginView: Box<LoginView>

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if viewModel.dataLoaded && scenePhase == .active && viewModel.scnView != nil {
                viewModel.scnView
                .frame(width: UIScreen.main.bounds.size.width,
                           height: UIScreen.main.bounds.height,
                           alignment: .center)
                    .zIndex(1)
                if viewModel.showInfo {
                        if let atom = viewModel.selectedAtom, let atomInfo = viewModel.selectedAtomInfo {
                            AtomInfoView(atomInfo: atomInfo, atom: atom)
                            .padding(10)
                            .frame(width: UIScreen.main.bounds.size.width,
                                   height: UIScreen.main.bounds.height / 2,
                                   alignment: .top)
                            .zIndex(3)
                            .background(Color(UIColor.gray.withAlphaComponent(0.7)))
                            .cornerRadius(20, corners: .topLeft)
                            .cornerRadius(20, corners: .topRight)
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    .onEnded({ value in
                                        if value.translation.height > 0 {
                                            viewModel.unselected()
                                        }
                                    }))
                        }
                }
                else {
                    HStack {
                        Button(action:viewModel.toggleShowHydrogens) {
                            Image(systemName: "atom")
                                .padding(30)
                                .foregroundColor(viewModel.showHydrogens ? Color.gray : Color.blue)
                        }
                        Button(action:{viewModel.share()}) {
                            Image(systemName: "square.and.arrow.up")
                                .padding(30)
                        }
                        Button(action: viewModel.randColor) {
                            Image(systemName: "paintbrush")
                                .padding(30)
                        }
                    }.zIndex(2)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(width: UIScreen.main.bounds.size.width,
               height: UIScreen.main.bounds.height,
               alignment: .center)
        .onChange(of: scenePhase) { phase in
            if phase == .background || phase == .inactive {
                lock()
            } else if phase == .active && viewModel.scnView == nil {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            print("opened \(viewModel.ligand!.name)  \(id)")
        }
        
    }
    
    init(modelView: LigandViewViewMode, logBox: Box<LoginView>) {
        self.loginView = logBox
        self.viewModel = modelView
    }
}

