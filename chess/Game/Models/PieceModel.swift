//
//  PieceModel.swift
//  chess
//
//  Created by Algirdas Jasaitis on 22/12/2023.
//

import Foundation

enum PieceModel: Equatable {
    case empty
    case pawn(PlayerModel)
    case rook(PlayerModel)
    case bishop(PlayerModel)
    case knight(PlayerModel)
    case king(PlayerModel)
    case queen(PlayerModel)
    
    var imageName: String? {
        switch self {
        case .empty:
            return nil
        case .pawn(let player):
            return player == .white ? "wP" : "bP"
        case .rook(let player):
            return player == .white ? "wR" : "bR"
        case .bishop(let player):
            return player == .white ? "wB" : "bB"
        case .knight(let player):
            return player == .white ? "wN" : "bN"
        case .king(let player):
            return player == .white ? "wK" : "bK"
        case .queen(let player):
            return player == .white ? "wQ" : "bQ"
        }
    }
    
    var hasMoved: Bool {
        // This could be modified in the future to track if pieces have moved
        // (important for castling and pawn's first move)
        switch self {
        case .empty:
            return false
        default:
            return false
        }
    }
    
    static func == (lhs: PieceModel, rhs: PieceModel) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case let (.pawn(player1), .pawn(player2)),
             let (.rook(player1), .rook(player2)),
             let (.bishop(player1), .bishop(player2)),
             let (.knight(player1), .knight(player2)),
             let (.king(player1), .king(player2)),
             let (.queen(player1), .queen(player2)):
            return player1 == player2
        default:
            return false
        }
    }
}
