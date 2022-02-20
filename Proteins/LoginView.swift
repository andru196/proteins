//
//  LoginView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 18.02.2022.
//

import SwiftUI

struct LoginView: View {
    private var viewList: ContentView? = nil
    private var ligandView: LigandView? = nil
    //@State var loggedState = false
    
    @ObservedObject var model: Model

    
    var body: some View {
        ZStack {
            if model.lock {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    .onTapGesture {
                        self.model.lock = false
                        model.reloadView()
                    }
            } else {
                if let view = viewList {
                    view
                } else {
                    ligandView!
                }
            }
        }
    }
    mutating func lock<T> (nextView: T) where T: BaseView {
        model.lock = true
        if let view = nextView as? LigandView {
            ligandView = view
        } else {
            viewList = nextView as? ContentView
        }
        model.reloadView()
    }
    
    init() {
        self.model = Model()
    }
}

class Model: ObservableObject {
    var lock = false
    func reloadView() {
        objectWillChange.send()
    }
}
