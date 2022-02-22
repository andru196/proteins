//
//  HasApply.swift
//  Proteins
//
//  Created by Andrew Tarasow on 22.02.2022.
//

import Foundation

protocol HasApply { }

extension HasApply {
    func apply(closure:(Self) -> ()) -> Self {
        closure(self)
        return self
    }
}
