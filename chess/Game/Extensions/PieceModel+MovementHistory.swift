//
//  PieceModel+MovementHistory.swift
//  chess
//
//  Created by Algirdas Jasaitis on 26/03/2025.
//

import Foundation

extension PieceModel {
    func hasMoved(at position: (row: Int, col: Int), moveHistory: [MoveModel]) -> Bool {
        guard self != .empty else { return false }
        
        switch self {
        case .king(let player):
            let initialRow = player == .white ? 7 : 0
            let initialCol = 4
            
            if position.row != initialRow || position.col != initialCol {
                return true
            }
            
            return moveHistory.contains { move in
                if case .king(let movePlayer) = move.piece, movePlayer == player {
                    return move.fromRow == initialRow && move.fromCol == initialCol
                }
                return false
            }
            
        case .rook(let player):
            let initialRow = player == .white ? 7 : 0
            let initialCols = [0, 7]
            
            if position.row != initialRow || !initialCols.contains(position.col) {
                return true
            }
            
            return moveHistory.contains { move in
                if case .rook(let movePlayer) = move.piece, movePlayer == player {
                    return move.fromRow == initialRow && move.fromCol == position.col
                }
                return false
            }
            
        case .pawn(let player):
            let initialRow = player == .white ? 6 : 1
            
            if position.row != initialRow {
                return true
            }
            
            return moveHistory.contains { move in
                if case .pawn(let movePlayer) = move.piece, movePlayer == player {
                    return move.fromRow == initialRow && move.fromCol == position.col
                }
                return false
            }
            
        default:
            return false
        }
    }
}
