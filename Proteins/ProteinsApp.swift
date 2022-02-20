//
//  ProteinsApp.swift
//  Proteins
//
//  Created by Andrew Tarasow on 09.01.2022.
//

import SwiftUI

@main
struct ProteinsApp: App {

    var logginView: LoginView!
    
    var body: some Scene {
        WindowGroup {
            logginView
        }
    }
    func prepareView() -> LoginView{
        var lview = LoginView()
        let box = Box(value: lview)
        let lst = ContentView(ligands: Ligands(names: readLigandsList()), atoms: readAtomInfos(), logView: box, loginState: lview.model)
        lview.lock(nextView: lst)
        return lview
    }
    
    init() {
        
        Configurator.configure()
        self.logginView = prepareView()
        UITableView.appearance().backgroundColor = .clear
        
    }
    
    
    func readLigandsList() -> [String] {
        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let text = try String(contentsOfFile: path, encoding: .utf8)
                let ligands = text.split(separator: "\n")
                return ligands.map({
                    String($0)
                })
            } catch _ {
                //TODO: some error msg
                exit(1)
            }
        }
        return []
    }
    
    func readAtomInfos() -> [String: AtomInfo] {
        var result = [String: AtomInfo]()
        if let jsonText = Files.readFile(file: "PeriodicTable", ext: "json") {
            let data = jsonText.data(using: .utf8)!
            do {
                if let root = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,[Any]>
                {
                    for a in root["elements"]! {
                        if let atom = a as? Dictionary<String, Any> {
                            let atomInfo = AtomInfo(name: atom["name"] as! String,
                                                    appearance: atom["appearance"] as? String,
                                                    atomicMass: (atom["atomic_mass"] as! NSNumber).floatValue,
                                                    boil: (atom["boil"] as? NSNumber)?.floatValue,
                                                    catigory: atom["catigory"] as? String,
                                                    density: (atom["density"] as? NSNumber)?.floatValue,
                                                    discoverVy: atom["discovered_by"] as? String,
                                                    melt: (atom["melt"] as? NSNumber)?.floatValue,
                                                    molarHeat: (atom["molar_heat"] as? NSNumber)?.floatValue,
                                                    namedBy: atom["named_by"] as? String,
                                                    number: (atom["number"] as! NSNumber).intValue,
                                                    period: (atom["period"] as! NSNumber).intValue,
                                                    phase: atom["phase"] as! String,
                                                    source: atom["source"] as! String,
                                                    spectralImage: atom["spectral_img"] as? String,
                                                    summary: atom["summary"] as! String,
                                                    symbol: atom["symbol"] as! String,
                                                    xpos: (atom["xpos"] as! NSNumber).intValue,
                                                    ypos: (atom["ypos"] as! NSNumber).intValue,
                                                    shells: atom["shells"] as! [Int],
                                                    electronConfiguration: atom["electron_configuration"] as! String,
                                                    electronConfigurationSemantic: atom["electron_configuration_semantic"] as! String,
                                                    electronAffinity: (atom["electron_affinity"] as? NSNumber)?.floatValue,
                                                    electronegativityPauling: (atom["electronegativity_pauling"] as? NSNumber)?.floatValue,
                                                    ionizationEnergies: (atom["ionization_energies"] as! [NSNumber]).map({$0.floatValue}),
                                                    cpkHex: atom["cpk-hex"] as? String)
                            result[atomInfo.symbol] = atomInfo
                        }
                    }
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
        }
        return result
    }
}
