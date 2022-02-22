//
//  PDBReader.swift
//  Proteins
//
//  Created by Andrew Tarasow on 12.02.2022.
//

import Foundation

class PDBReader {
    private func lineToAtom(elements: [Substring.SubSequence]) -> PDBAtom {
        return PDBAtom(name: String(elements[2]),
                       element: String(elements[11]),
                       number: Int(String(elements[1]))! - 1,
                       x: Double(String(elements[6]))!,
                       y: Double(String(elements[7]))!,
                       z: Double(String(elements[8]))!)
    }
    
    func read(text: String) -> PdbDocument {
        var atoms = [PDBAtom]()
        var connections = [PDBConnect]()
        let lines = text.split(separator: "\n")

        for line in lines {
            let elements = line.split(separator: " ")
            let type = LineType(rawValue: String(elements[0]))
            switch type {
            case .ATOM:
                let atom = lineToAtom(elements: elements)
                atoms.append(atom)
            case .CONECT:
                let target = Int(String(elements[1]))! - 1
                for element in elements[2...] {
                    let conn = PDBConnect(first: target,
                                       second: Int(String(element))! - 1)
                    var j = -1
                    if let _ = connections.first(where: { x in
                        j += 1
                        return (x.first == conn.first && x.second == conn.second)
                        || (x.second == conn.first && x.first == conn.second )
                        
                    })
                    {
                        connections.remove(at: j)
                        //conn.isDouble = true
                    }
                    connections.append(conn)
                }
            case .END:
                break
            default:
                print("fck: \(line)")
            }
        }
        return PdbDocument(atoms: atoms.sorted(by: {$0.number < $1.number}), connections: connections)
    }
}

