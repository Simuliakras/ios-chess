//
//  ChessRulesService.swift
//  chess
//
//  Created by Algirdas Jasaitis on 26/03/2025.
//

import Foundation

struct ChessRulesService {
    static func isValidMove(
        fromRow: Int,
        fromCol: Int,
        toRow: Int,
        toCol: Int,
        board: BoardModel,
        piece: PieceModel,
        lastMove: MoveModel?,
        moveHistory: [MoveModel]
    ) -> Bool {
        // Check that we're not moving to the same square
        if fromRow == toRow && fromCol == toCol {
            return false
        }
        
        // Check destination square - can't capture own pieces
        let destinationPiece = board[toRow, toCol]
        if destinationPiece != .empty && destinationPiece.belongsToPlayer(piece.player!) {
            return false
        }
        
        // Now pass the move history to MovesValidationService
        return MovesValidationService.isValidMove(
            fromRow: fromRow,
            fromCol: fromCol,
            toRow: toRow,
            toCol: toCol,
            board: board.pieces,
            piece: piece,
            lastMove: lastMove,
            moveHistory: moveHistory
        )
    }
    
    static func isSquareAttacked(
        row: Int,
        col: Int,
        by player: PlayerModel,
        board: BoardModel,
        moveHistory: [MoveModel]
    ) -> Bool {
        return MovesValidationService.isSquareAttacked(
            row: row,
            col: col,
            by: player,
            board: board.pieces,
            moveHistory: moveHistory
            
        )
    }
}
