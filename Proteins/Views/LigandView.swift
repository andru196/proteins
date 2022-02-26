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
    @State var move: CGFloat = 0
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
                            .offset(y: move)
                            .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .local)
                                        .onChanged { value in
                                withAnimation() {
                                    let delta = value.translation.height
                                    if delta > 50 {
                                        move = 50
                                    } else if delta < 50 {
                                        move = -50
                                    } else {
                                        move = delta
                                    }
                                }
                            }
                                        .onEnded { value in
                                if value.translation.height > 15 {
                                    withAnimation {
                                        move = value.translation.height
                                        viewModel.unselected()
                                    }
                                } else {
                                    withAnimation {
                                        move = 0
                                    }
                                }
                            })
                            .onAppear {
                                move = 0
                            }
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
            if phase == .background {//}|| phase == .inactive {
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

