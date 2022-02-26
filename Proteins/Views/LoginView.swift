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
    
    @State private var anime: CGFloat =  1
    
    var body: some View {
        ZStack {
            if model.locked {
                VStack {
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
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .background(LinearGradient(colors:[Color(UIColor.blue.withAlphaComponent(0.5)),
                                                   Color(UIColor.yellow.withAlphaComponent(0.5))], startPoint: .top, endPoint: .bottom))
                .scaleEffect(anime)
                .onAppear {
                    if anime > 1 {
                        anime = 1
                    }
                    return withAnimation(.linear(duration: 11)) {
                        self.anime += 0.6
                    }
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
            print("Phase change to \(phase)")
        }
        .alert(isPresented: $model.showingALert) {
            Alert(title: Text("NO"),
                  message: Text("U can't see content without authentication"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    mutating func lock<T> (nextView: T) where T: BaseView {
        if !model.locked {
            if let view = nextView as? LigandView {
                ligandView = view
                viewList = nil
            } else {
                viewList = nextView as? LigandsListView
                ligandView = nil
            }
            model.lock()
            print("app locked")
        } else {
            print("still locked")
        }
    }
    
    
    init(model: Model) {
        self.model = model
    }
}
