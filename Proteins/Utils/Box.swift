//
//  Box.swift
//  Proteins
//
//  Created by Andrew Tarasow on 18.02.2022.
//

import Foundation

class Box<T>: ObservableObject {
   var value: T!
   init(value: T? = nil) {
       if let v = value {
           self.value = v
       }
   }
}
