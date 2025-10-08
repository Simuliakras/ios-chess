//
//  GameStateService.swift
//  chess
//
//  Created by Algirdas Jasaitis on 26/03/2025.
//

import Foundation

struct GameStateService {
    private let moveHistory: [MoveModel]
    
    init(moveHistory: [MoveModel]) {
        self.moveHistory = moveHistory
    }
    
    func determineGameState(
        board: BoardModel,
        currentPlayer: PlayerModel,
        kingPosition: (row: Int, col: Int)
    ) -> GameStateModel {
        let isInCheck = ChessRulesService.isSquareAttacked(
            row: kingPosition.row,
            col: kingPosition.col,
            by: currentPlayer.opponent,
            board: board,
            moveHistory: moveHistory
        )
        
        if isInCheck {
            return hasLegalMoves(board: board, player: currentPlayer, kingPosition: kingPosition)
                ? .check
                : .checkmate
        } else {
            return hasLegalMoves(board: board, player: currentPlayer, kingPosition: kingPosition)
                ? .active
                : .stalemate
        }
    }
    
    private func hasLegalMoves(board: BoardModel, player: PlayerModel, kingPosition: (row: Int, col: Int)) -> Bool {
        for fromRow in 0..<8 {
            for fromCol in 0..<8 {
                let piece = board[fromRow, fromCol]
                if piece != .empty && piece.belongsToPlayer(player) {
                    for toRow in 0..<8 {
                        for toCol in 0..<8 {
                            if canMakeValidMove(
                                board: board,
                                fromRow: fromRow,
                                fromCol: fromCol,
                                toRow: toRow,
                                toCol: toCol,
                                piece: piece,
                                player: player,
                                kingPosition: kingPosition
                            ) {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    private func canMakeValidMove(
        board: BoardModel,
        fromRow: Int,
        fromCol: Int,
        toRow: Int,
        toCol: Int,
        piece: PieceModel,
        player: PlayerModel,
        kingPosition: (row: Int, col: Int)
    ) -> Bool {
        guard ChessRulesService.isValidMove(
            fromRow: fromRow,
            fromCol: fromCol,
            toRow: toRow,
            toCol: toCol,
            board: board,
            piece: piece,
            lastMove: nil,
            moveHistory: moveHistory
        ) else {
            return false
        }
        
        var tempBoard = board.copy()
        tempBoard[toRow, toCol] = piece
        tempBoard[fromRow, fromCol] = .empty
        
        var tempKingPosition = kingPosition
        if case .king = piece {
            tempKingPosition = (toRow, toCol)
        }
        
        return !ChessRulesService.isSquareAttacked(
            row: tempKingPosition.row,
            col: tempKingPosition.col,
            by: player.opponent,
            board: tempBoard,
            moveHistory: moveHistory
        )
    }
}
