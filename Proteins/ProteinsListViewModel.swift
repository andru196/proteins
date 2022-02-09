//
//  ProteinsListViewModel.swift
//  Proteins
//
//  Created by Andrew Tarasow on 09.01.2022.
//
import Combine
import Foundation

//final class ProteinsListViewModel: ObservableObject {
//    @Published var searchText: String = ""
//    @Published var findedList: Int32 = 3
//    
//    let fullSet: Array<String> = ["a", "b", "c"]
//    
//    init() {
//        $searchText
//            .debounce(for: 0.3, scheduler: RunLoop.main)
//            .removeDuplicates()
//            .flatMap(x -> x)
//            .flatMap{ (search:String) -> Int32 in
//                Int32(search) ?? 1}
//            .assign(to: \.findedList, on: self)
//            
//    }
//}
