//
//  ChessViewModel.swift
//  chess
//
//  Created by Algirdas Jasaitis on 26/03/2025.
//

import Foundation
import Combine

class ChessViewModel: ObservableObject {
    @Published private(set) var board: BoardModel
    @Published private(set) var currentPlayer: PlayerModel = .white
    @Published private(set) var gameState: GameStateModel = .active
    
    private let moveHistoryService = MoveHistoryService()
    
    var whiteKingPosition: (row: Int, col: Int)
    var blackKingPosition: (row: Int, col: Int)
    
    init() {
        let setup = BoardSetupService.setupStandardGame()
        self.board = setup.0
        self.blackKingPosition = setup.1
        self.whiteKingPosition = setup.2
    }
    
    func newGame() {
        let setup = BoardSetupService.setupStandardGame()
        self.board = setup.0
        self.blackKingPosition = setup.1
        self.whiteKingPosition = setup.2
        
        moveHistoryService.clear()
        currentPlayer = .white
        updateGameState()
    }
    
    func canMovePiece(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int) -> Bool {
        guard BoardModel.isValidPosition(row: fromRow, col: fromCol),
              BoardModel.isValidPosition(row: toRow, col: toCol) else {
            return false
        }
        
        let piece = board[fromRow, fromCol]
        
        guard piece != .empty, piece.belongsToPlayer(currentPlayer) else {
            return false
        }
        
        guard ChessRulesService.isValidMove(
            fromRow: fromRow,
            fromCol: fromCol,
            toRow: toRow,
            toCol: toCol,
            board: board,
            piece: piece,
            lastMove: moveHistoryService.lastMove,
            moveHistory: moveHistoryService.moves
        ) else {
            return false
        }
        
        // Make a temporary move to check if it leaves the king in check
        var tempBoard = board.copy()
        tempBoard[toRow, toCol] = piece
        tempBoard[fromRow, fromCol] = .empty
        
        // Handle en passant capture
        if case .pawn = piece,
           abs(fromCol - toCol) == 1,
           tempBoard[toRow, toCol] == .empty {
            tempBoard[fromRow, toCol] = .empty
        }
        
        // Handle castling
        if case .king = piece, abs(fromCol - toCol) == 2 {
            let isKingSide = toCol > fromCol
            let rookCol = isKingSide ? 7 : 0
            let rookNewCol = isKingSide ? toCol - 1 : toCol + 1
            
            tempBoard[fromRow, rookNewCol] = tempBoard[fromRow, rookCol]
            tempBoard[fromRow, rookCol] = .empty
        }
        
        var kingPosition = currentPlayer == .white ? whiteKingPosition : blackKingPosition
        if case .king = piece {
            kingPosition = (toRow, toCol)
        }
        
        return !ChessRulesService.isSquareAttacked(
            row: kingPosition.row,
            col: kingPosition.col,
            by: currentPlayer.opponent,
            board: tempBoard,
            moveHistory: moveHistoryService.moves
        )
    }
    
    func movePiece(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int) -> Bool {
        guard gameState == .active || gameState == .check else {
            return false
        }
        
        guard canMovePiece(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol) else {
            return false
        }
        
        let movingPiece = board[fromRow, fromCol]
        let targetPiece = board[toRow, toCol]
        
        var move = MoveModel(
            fromRow: fromRow,
            fromCol: fromCol,
            toRow: toRow,
            toCol: toCol,
            piece: movingPiece,
            capturedPiece: targetPiece != .empty ? targetPiece : nil
        )
        
        if case .pawn = movingPiece,
           abs(fromCol - toCol) == 1,
           board[toRow, toCol] == .empty {
            move.isEnPassant = true
            move.capturedPiece = board[fromRow, toCol]
            board[fromRow, toCol] = .empty
        }
        
        if case .king = movingPiece, abs(fromCol - toCol) == 2 {
            move.isCastling = true
            let isKingSide = toCol > fromCol
            let rookCol = isKingSide ? 7 : 0
            let rookNewCol = isKingSide ? toCol - 1 : toCol + 1
            
            board[fromRow, rookNewCol] = board[fromRow, rookCol]
            board[fromRow, rookCol] = .empty
        }
        
        if case .king = movingPiece {
            if currentPlayer == .white {
                whiteKingPosition = (toRow, toCol)
            } else {
                blackKingPosition = (toRow, toCol)
            }
        }
        
        board[toRow, toCol] = movingPiece
        board[fromRow, fromCol] = .empty
        
        // Handle pawn promotion (always to queen for now)
        if case .pawn = movingPiece, (toRow == 0 || toRow == 7) {
            move.isPromotion = true
            let promotedPiece = PieceModel.queen(currentPlayer)
            board[toRow, toCol] = promotedPiece
            move.promotedTo = promotedPiece
        }
        
        moveHistoryService.recordMove(move)
        
        switchPlayerTurn()
        return true
    }
    
    private func switchPlayerTurn() {
        currentPlayer = currentPlayer.next
        updateGameState()
    }
    
    private func updateGameState() {
        let stateManager = GameStateService(moveHistory: moveHistoryService.moves)
        gameState = stateManager.determineGameState(
            board: board,
            currentPlayer: currentPlayer,
            kingPosition: currentPlayer == .white ? whiteKingPosition : blackKingPosition
        )
    }
    
    var capturedPieces: [PieceModel] {
        return moveHistoryService.capturedPieces
    }
    
    var moveHistory: [MoveModel] {
        return moveHistoryService.moves
    }
    
    func pieceAt(row: Int, col: Int) -> PieceModel? {
        guard BoardModel.isValidPosition(row: row, col: col) else { return nil }
        return board[row, col]
    }
    
    func isKingInCheck(player: PlayerModel) -> Bool {
        let kingPosition = player == .white ? whiteKingPosition : blackKingPosition
        return ChessRulesService.isSquareAttacked(
            row: kingPosition.row,
            col: kingPosition.col,
            by: player.opponent,
            board: board,
            moveHistory: moveHistoryService.moves
        )
    }
    
    func hasPieceMoved(at position: (row: Int, col: Int)) -> Bool {
        guard BoardModel.isValidPosition(row: position.row, col: position.col) else {
            return false
        }
        
        let piece = board[position.row, position.col]
        return piece.hasMoved(at: position, moveHistory: moveHistoryService.moves)
    }
}
