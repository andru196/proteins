//
//  LoginView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 18.02.2022.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    private var viewList: LigandsListView? = nil
    private var ligandView: LigandView? = nil
    
    @Environment(\.scenePhase) var _scenePhase
    @ObservedObject var model: Model
    
    var body: some View {
        ZStack {
            if model.locked {
                    Button(action: {
                        if model.locked {
                            model.authenticate()
                        }
                    }) {
                        Image(systemName: model.canUseBiometric ? "touchid" : "lock")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                            .padding(40)
                    }
                
            } else {
                if let view = viewList {
                    view
                } else {
                    ligandView!
                }
            }
        }
        .onChange(of: _scenePhase) { phase in
            if phase == .background {
                model.lock()
            }
            print(phase)
        }
        .alert(isPresented: $model.showingALert) {
            Alert(title: Text("NO"),
                  message: Text("U can't see content without authentication"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    mutating func lock<T> (nextView: T) where T: BaseView {
        
        if let view = nextView as? LigandView {
            ligandView = view
            viewList = nil
        } else {
            viewList = nextView as? LigandsListView
            ligandView = nil
        }
        model.lock()
        print("app locked")
    }
    
    
    init(model: Model) {
        self.model = model
    }
}
