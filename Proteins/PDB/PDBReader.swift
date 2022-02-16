//
//  PDBReader.swift
//  Proteins
//
//  Created by Andrew Tarasow on 12.02.2022.
//

import Foundation

struct PdbDocument {
    let atoms: [Atom]
    let connections: [Connect]
}

struct Atom {
    let name: String
    let element: String
    let number: Int
    let x: Double
    let y: Double
    let z: Double
}

struct Connect {
    let first: Int
    let second: Int
}

class PDBReader {
    func read(text: String) -> PdbDocument {
        var atoms = [Atom]()
        var connections = [Connect]()
        let lines = text.split(separator: "\n")

        for line in lines {
            let elements = line.split(separator: " ")
            let type = LineType(rawValue: String(elements[0]))
            switch type {
            case .ATOM:
                let atom = Atom(name: String(elements[2]),
                                element: String(elements[11]),
                                number: Int(String(elements[1]))! - 1,
                                x: Double(String(elements[6]))!,
                                y: Double(String(elements[7]))!,
                                z: Double(String(elements[8]))!)
                atoms.append(atom)
            case .CONECT:
                let conn = Connect(first: Int(String(elements[1]))! - 1,
                                   second: Int(String(elements[2]))! - 1)
                connections.append(conn)
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

