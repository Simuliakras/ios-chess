//
//  PieceModel+Player.swift
//  chess
//
//  Created by Algirdas Jasaitis on 26/03/2025.
//

import Foundation

extension PieceModel {
    func belongsToPlayer(_ player: PlayerModel) -> Bool {
        switch self {
        case .empty:
            return false
        case .pawn(let piecePlayer), .rook(let piecePlayer), .bishop(let piecePlayer),
             .knight(let piecePlayer), .king(let piecePlayer), .queen(let piecePlayer):
            return piecePlayer == player
        }
    }
    
    var player: PlayerModel? {
        switch self {
        case .empty:
            return nil
        case .pawn(let player), .rook(let player), .bishop(let player),
             .knight(let player), .king(let player), .queen(let player):
            return player
        }
    }
}
