//
//  Files.swift
//  Proteins
//
//  Created by Andrew Tarasow on 15.02.2022.
//

import Foundation

class Files {
    static func readFile(file: String, ext: String) -> String? {
        if let path = Bundle.main.path(forResource: file, ofType: ext) {
            do {
                return try String(contentsOfFile: path, encoding: .utf8)
            } catch _ {
                //TODO: some error msg
                exit(1)
            }
        }
        return nil
    }
}
