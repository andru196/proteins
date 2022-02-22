//
//  LineType.swift
//  Proteins
//
//  Created by Andrew Tarasow on 22.02.2022.
//

import Foundation

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
