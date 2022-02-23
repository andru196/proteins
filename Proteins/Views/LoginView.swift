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
    @State private var showingALert = false
    
    var body: some View {
        ZStack {
            if model.lock {
                 
                    Button(action: {
                        if model.lock {
                            authenticate()
                        }
                    }) {
                        Image(systemName: canUseBiometric ? "touchid" : "lock")
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
                model.lock = true
            }
            print(phase)
        }
        .alert(isPresented: $showingALert) {
            Alert(title: Text("NO"),
                  message: Text("U can't see content without authentication"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    mutating func lock<T> (nextView: T) where T: BaseView {
        model.lock = true
        if let view = nextView as? LigandView {
            ligandView = view
            viewList = nil
        } else {
            viewList = nextView as? LigandsListView
            ligandView = nil
        }
        model.reloadView()
        print("app locked")
    }
    
    let canUseBiometric: Bool
    init() {
        self.model = Model()
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"
        var authorizationError: NSError?

        if localAuthenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authorizationError) {

            print("Biometrics is supported. User can use Passcode option if needed.")
            canUseBiometric = true
        } else {
            canUseBiometric = false
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    model.lock = false
                } else {
                    model.lock = true
                    showingALert = true
                }
            }
        } else {
            // no biometrics
        }
    }
}

class Model: ObservableObject {
    var lock = false
    {
        didSet {
            DispatchQueue.main.async {
                self.reloadView()
            }
            
        }
    }
    
    func reloadView() {
        objectWillChange.send()
    }
}
