//
//  MoveModel.swift
//  chess
//
//  Created by Algirdas Jasaitis on 28/12/2023.
//

import Foundation

struct MoveModel: Hashable {
    let fromRow: Int
    let fromCol: Int
    let toRow: Int
    let toCol: Int
    let piece: PieceModel
    var capturedPiece: PieceModel?
    var isPromotion: Bool = false
    var promotedTo: PieceModel?
    var isCastling: Bool = false
    var isEnPassant: Bool = false

    func hash(into hasher: inout Hasher) {
        hasher.combine(fromRow)
        hasher.combine(fromCol)
        hasher.combine(toRow)
        hasher.combine(toCol)
    }

    static func == (lhs: MoveModel, rhs: MoveModel) -> Bool {
        // We also don't include the additional properties in equality check
        // to maintain backward compatibility
        return lhs.fromRow == rhs.fromRow &&
               lhs.fromCol == rhs.fromCol &&
               lhs.toRow == rhs.toRow &&
               lhs.toCol == rhs.toCol &&
               lhs.piece.imageName == rhs.piece.imageName
    }
}
