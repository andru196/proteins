//
//  Bool.swift
//  Proteins
//
//  Created by Andrew Tarasow on 22.02.2022.
//

import Foundation

extension Bool {
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
}
