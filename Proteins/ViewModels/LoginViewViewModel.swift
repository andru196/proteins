//
//  LoginViewViewModel.swift
//  Proteins
//
//  Created by Andrew Tarasow on 23.02.2022.
//

import Foundation
import LocalAuthentication

class Model: ObservableObject {
    @Published var showingALert = false
    @Published private(set) var locked = false
    let canUseBiometric: Bool
    
    
    func reloadView() {
        objectWillChange.send()
    }
    
    func lock() {
        locked = true
    }
    
    init() {
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
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.sync {
                    if success {
                        self.locked = false
                        print("App unlocked")
                    } else {
                        self.locked = true
                        self.showingALert = true
                    }
                }
            }
        } else {
            self.locked = true
            self.showingALert = true
        }
    }
}
