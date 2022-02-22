//
//  String.swift
//  Proteins
//
//  Created by Andrew Tarasow on 21.02.2022.
//

import Foundation

extension String {
    func join(elements: [String]) -> String {
        var rez = ""
        var i = 0
        for s in elements {
            i += 1
            if i == elements.count {
                rez += s
            } else {
                rez += s + self
            }
        }
        return rez
    }
}
