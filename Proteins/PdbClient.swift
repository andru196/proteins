//
//  PdbClient.swift
//  Proteins
//
//  Created by Andrew Tarasow on 15.02.2022.
//

import Foundation

class PdbClient {
    
    let pdbReader: PDBReader
    init(pdbReader: PDBReader) {
        self.pdbReader = pdbReader
    }
    
    // fake
    func geFaketPdb(name: String) -> PdbDocument {
        let text = Files.readFile(file: "011_ideal.pdb", ext: "txt")!
        return pdbReader.read(text: text)
    }
    
    func gePdb(name: String) -> PdbDocument {
        let url = URL(string: "http://files.rcsb.org/ligands/view/\(name)_ideal.pdb")!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        var text = ""
        let semaphore = DispatchSemaphore(value: 0)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                semaphore.signal()
                return
            }
            guard let data = data else {
                semaphore.signal()
                return
            }
            text = String(data: data, encoding: .utf8)!
            print(text)
            semaphore.signal()
        })
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return pdbReader.read(text: text)
    }
    
    
}
