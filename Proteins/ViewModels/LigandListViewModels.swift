//
//  LigandListViewModels.swift
//  Proteins
//
//  Created by Andrew Tarasow on 23.02.2022.
//

import Foundation


class Ligands: ObservableObject {
    private(set)var  items: [Ligand]

    @Published var searchText: String = ""
    @Published private(set) var selectedLigand: Ligand!
    @Published var showingDetail = false
    @Published var ligandView: LigandView!
    @Published var loadedUnsuccess = false
    @Published var isLoading = false
    
    func selectLigand(_ ligand: Ligand?) {
        self.selectedLigand = ligand
    }
    
    func onAppearLoading(loader: @escaping (Ligand) -> Bool) {
        if isLoading && selectedLigand != nil {
            DispatchQueue.main.async {
                self.loadedUnsuccess = !loader(self.selectedLigand)
                self.isLoading = false
                if !self.loadedUnsuccess {
                    self.showingDetail = true
                }
            }
        }
    }
    
    init(names: [String]) {
        var _items = [Ligand]()
        for name in names {
            _items.append(Ligand(name: name))
        }
        items = _items
    }
}
