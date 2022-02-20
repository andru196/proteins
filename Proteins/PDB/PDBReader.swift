//
//  PDBReader.swift
//  Proteins
//
//  Created by Andrew Tarasow on 12.02.2022.
//

import Foundation

struct PdbDocument {
    let atoms: [PDBAtom]
    let connections: [PDBConnect]
}

struct PDBAtom {
    let name: String
    let element: String
    let number: Int
    let x: Double
    let y: Double
    let z: Double
}

struct PDBConnect {
    let first: Int
    let second: Int
}

class PDBReader {
    func read(text: String) -> PdbDocument {
        var atoms = [PDBAtom]()
        var connections = [PDBConnect]()
        let lines = text.split(separator: "\n")

        for line in lines {
            let elements = line.split(separator: " ")
            let type = LineType(rawValue: String(elements[0]))
            switch type {
            case .ATOM:
                let atom = PDBAtom(name: String(elements[2]),
                                element: String(elements[11]),
                                number: Int(String(elements[1]))! - 1,
                                x: Double(String(elements[6]))!,
                                y: Double(String(elements[7]))!,
                                z: Double(String(elements[8]))!)
                atoms.append(atom)
            case .CONECT:
                let target = Int(String(elements[1]))! - 1
                for element in elements[1...] {
                    let conn = PDBConnect(first: target,
                                       second: Int(String(element))! - 1)
                    connections.append(conn)
                }
            case .END:
                break
            default:
                print("fck: \(line)")
                //                        exit(1)
            }
        }
        return PdbDocument(atoms: atoms.sorted(by: {$0.number < $1.number}), connections: connections)
    }
}

enum LineType: String {
    case HEADER = "HEADER"
    case TITLE = "TITLE"
    case EXPDTA = "EXPDTA"
    case AUTHOR = "AUTHOR"
    case REMARK = "REMARK"
    case SEQRES = "SEQRES"
    case ATOM = "ATOM"
    case HETATM = "HETATM"
    case CONECT = "CONECT"
    case END = "END"
    
}

