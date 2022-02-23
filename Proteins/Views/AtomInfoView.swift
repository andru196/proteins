//
//  AtomInfoView.swift
//  Proteins
//
//  Created by Andrew Tarasow on 23.02.2022.
//

import SwiftUI

struct AtomInfoView: View {
    let atomInfo: AtomInfo
    let atom: PDBAtom
    let dic: KeyValuePairs<String, String>
    
    init(atomInfo: AtomInfo, atom: PDBAtom) {
        self.atomInfo = atomInfo
        self.atom = atom
        
        dic = ["Summary": atomInfo.summary,
         "Appearance": atomInfo.appearance ?? "NULL",
         "Atomic Mass": String(atomInfo.atomicMass) ,
         "Boil": String(atomInfo.boil ?? -1) ,
         "Category": atomInfo.catigory ?? "NULL",
         "Density": String(atomInfo.density ?? -1),
         "Discover By": atomInfo.discoverVy ?? "NULL",
         "Melt": String(atomInfo.melt ?? -1) ,
         "Molar Heat": String(atomInfo.molarHeat ?? -1) ,
         "Named By": atomInfo.namedBy ?? "NULL",
         "Number": String(atomInfo.number) ,
         "Period": String(atomInfo.period) ,
         "Phase": atomInfo.phase ,
         "X Posistion": String(atomInfo.xpos) ,
         "Y Position": String(atomInfo.ypos) ,
         "Shells": " ".join(elements: atomInfo.shells.map{String($0)}),
         "Electron Configuration": atomInfo.electronConfiguration ,
         "Electron Configuration Semantic": atomInfo.electronConfigurationSemantic ,
         "Electron Affinity": String(atomInfo.electronAffinity ?? -1) ,
         "Electronegativity Pauling": String(atomInfo.electronegativityPauling ?? -1) ,
         "Ionization Energies": " ".join(elements: atomInfo.ionizationEnergies.map{String($0)}),
         "CPK Hex": atomInfo.cpkHex ?? "NULL"
        ]
    }
    
    var body: some View {
        VStack
        {
            Text(atomInfo.name)
                .font(.largeTitle)
            HStack{
                Text(atom.element).fontWeight(.bold)
                Text(atom.name)
                Link("Wikipedia", destination: URL(string: atomInfo.source)!)
                    .padding(.leading, 10)
            }
            
            if let dic = self.dic {
                List {
                    ForEach (dic, id: \.key) { kv in
                        Section(header:Text(kv.key)){
                            Text(kv.value)
                                .onTapGesture(count: 2) {
                                    UIPasteboard.general.string = kv.value
                                }
                        }
                        .listRowBackground(Color.clear)
                        
                    }
                }.listStyle(GroupedListStyle())
                    .background(Color.clear)
            }
            
        }
    }
}

struct AtomInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AtomInfoView(atomInfo: AtomInfo(name: "C", appearance: "", atomicMass: 3, boil: 2, catigory: "dd", density: 3, discoverVy: "", melt: 33, molarHeat: 3, namedBy: "", number: 3, period: 3, phase: "", source: "", spectralImage: "", summary: "", symbol: "", xpos: 3, ypos: 2, shells: [3, 2], electronConfiguration: "", electronConfigurationSemantic: "", electronAffinity: 3, electronegativityPauling: 3, ionizationEnergies: [2.1, 3], cpkHex: nil),
                     atom: PDBAtom(name: "C", element: "C", number: 3, x: 3, y: 2, z: 1))
    }
}
