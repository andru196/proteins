//
//  BaseView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 18.02.2022.
//

import Foundation

import SwiftUI

protocol BaseView: View {
    var loginView: Box<LoginView> {get}
}

extension BaseView {
    func lock() {
        loginView.value.lock(nextView: self)
    }
}
