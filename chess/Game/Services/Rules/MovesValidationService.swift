//
//  MoveValidator.swift
//  chess
//
//  Created by Algirdas Jasaitis on 22/12/2023.
//

import Foundation

struct MovesValidationService {
    
    private static func index(forRow row: Int, col: Int) -> Int {
        return row * 8 + col
    }
    
    static func isInBounds(row: Int, col: Int) -> Bool {
        return row >= 0 && row < 8 && col >= 0 && col < 8
    }
    
    static func isPathClear(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int, board: [PieceModel]) -> Bool {
        let rowDirection = fromRow == toRow ? 0 : (toRow - fromRow) / abs(toRow - fromRow)
        let colDirection = fromCol == toCol ? 0 : (toCol - fromCol) / abs(toCol - fromCol)
        
        var currentRow = fromRow + rowDirection
        var currentCol = fromCol + colDirection
        
        while currentRow != toRow || currentCol != toCol {
            if board[index(forRow: currentRow, col: currentCol)] != .empty {
                return false
            }
            currentRow += rowDirection
            currentCol += colDirection
        }
        
        return true
    }
        
    static func isValidMove(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int, board: [PieceModel], piece: PieceModel, lastMove: MoveModel?, moveHistory: [MoveModel]) -> Bool {
        guard isInBounds(row: toRow, col: toCol) else {
            return false
        }
        
        let targetIndex = index(forRow: toRow, col: toCol)
        
        /// Check if targeting own piece
        if let piecePlayer = piece.player,
           board[targetIndex] != .empty &&
           board[targetIndex].belongsToPlayer(piecePlayer) {
            return false
        }
        
        switch piece {
        case .pawn:
            return isValidPawnMove(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board, lastMove: lastMove)
        case .knight:
            return isValidKnightMove(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board)
        case .bishop:
            return isValidBishopMove(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board)
        case .rook:
            return isValidRookMove(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board)
        case .queen:
            return isValidQueenMove(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board)
        case .king:
            return isValidKingMove(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board, moveHistory: moveHistory)
        case .empty:
            return false
        }
    }
    
    // MARK: - Pawn Move Validation
    
    static func isValidPawnMove(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int, board: [PieceModel], lastMove: MoveModel?) -> Bool {
        let movingPiece = board[index(forRow: fromRow, col: fromCol)]
        guard case let .pawn(player) = movingPiece else {
            return false
        }
        
        let forwardDirection = player == .white ? -1 : 1
        let initialRow = player == .white ? 6 : 1
        
        /// Check en passant first
        if isEnPassantMoveValid(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, lastMove: lastMove, board: board) {
            return true
        }
        
        /// Diagonal capture
        if abs(fromCol - toCol) == 1 && toRow - fromRow == forwardDirection {
            let targetPiece = board[index(forRow: toRow, col: toCol)]
            if targetPiece != .empty && !targetPiece.belongsToPlayer(player) {
                return true
            }
            return false
        }
        
        /// Forward moves: same column and target square must be empty.
        if toCol == fromCol && board[index(forRow: toRow, col: toCol)] == .empty {
            // Single move forward
            if toRow == fromRow + forwardDirection {
                return true
            }
            
            // Double move from initial position
            if fromRow == initialRow &&
               toRow == fromRow + 2 * forwardDirection &&
               board[index(forRow: fromRow + forwardDirection, col: fromCol)] == .empty {
                return true
            }
        }
        
        return false
    }
    
    static func isEnPassantMoveValid(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int, lastMove: MoveModel?, board: [PieceModel]) -> Bool {
        guard let lastMove = lastMove else { return false }
        
        let movingPiece = board[index(forRow: fromRow, col: fromCol)]
        if case let .pawn(piecePlayer) = movingPiece,
           board[index(forRow: toRow, col: toCol)] == .empty {
            
            /// Last piece that moved must be opponent's pawn
            let lastTarget = board[index(forRow: lastMove.toRow, col: lastMove.toCol)]
            if case let .pawn(lastPiecePlayer) = lastTarget,
               lastPiecePlayer != piecePlayer {
                
                let forwardDirection = piecePlayer == .white ? -1 : 1
                
                /// Check if the last move was a two-square pawn move
                if lastMove.toRow == fromRow &&
                   abs(lastMove.fromRow - lastMove.toRow) == 2 {
                    
                    /// En passant capture must be diagonal
                    if toRow == fromRow + forwardDirection &&
                       abs(toCol - fromCol) == 1 &&
                       toCol == lastMove.toCol {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // MARK: - Knight Move Validation
    
    static func isValidKnightMove(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int, board: [PieceModel]) -> Bool {
        let rowDiff = abs(toRow - fromRow)
        let colDiff = abs(toCol - fromCol)
        /// Knights move in an L-shape: (2,1) or (1,2)
        return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2)
    }
    
    // MARK: - Bishop Move Validation
    
    static func isValidBishopMove(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int, board: [PieceModel]) -> Bool {
        let rowDiff = abs(toRow - fromRow)
        let colDiff = abs(toCol - fromCol)
        
        /// Bishop must move diagonally and not remain in place.
        if rowDiff != colDiff || rowDiff == 0 {
            return false
        }
        
        return isPathClear(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board)
    }
    
    // MARK: - Rook Move Validation
    
    static func isValidRookMove(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int, board: [PieceModel]) -> Bool {
        if fromRow != toRow && fromCol != toCol {
            return false
        }
        return isPathClear(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board)
    }
    
    // MARK: - Queen Move Validation
    
    static func isValidQueenMove(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int, board: [PieceModel]) -> Bool {
        let rowDiff = abs(toRow - fromRow)
        let colDiff = abs(toCol - fromCol)
        
        /// Queen moves like bishop (diagonally) or rook (straight).
        if rowDiff == colDiff && rowDiff > 0 {
            return isPathClear(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board)
        }
        if (fromRow == toRow || fromCol == toCol) && (rowDiff > 0 || colDiff > 0) {
            return isPathClear(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board)
        }
        return false
    }
    
    // MARK: - King Move & Castling Validation
    
    static func isValidKingMove(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int, board: [PieceModel], moveHistory: [MoveModel]) -> Bool {
        let rowDiff = abs(toRow - fromRow)
        let colDiff = abs(toCol - fromCol)
        
        /// Regular king move: one square in any direction.
        if rowDiff <= 1 && colDiff <= 1 {
            guard case let .king(player) = board[index(forRow: fromRow, col: fromCol)] else {
                return false
            }
            
            /// Check if king would be in check after the move.
            var newBoard = board
            newBoard[index(forRow: toRow, col: toCol)] = board[index(forRow: fromRow, col: fromCol)]
            newBoard[index(forRow: fromRow, col: fromCol)] = .empty
            
            let opposingPlayer: PlayerModel = player == .white ? .black : .white
            if isSquareAttacked(row: toRow, col: toCol, by: opposingPlayer, board: newBoard, moveHistory: moveHistory) {
                return false
            }
            return true
        }
        
        /// Castling: king moves two squares horizontally.
        if rowDiff == 0 && colDiff == 2 {
            return isValidKingCastling(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol, board: board, moveHistory: moveHistory)
        }
        
        return false
    }
    
    static func isValidKingCastling(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int, board: [PieceModel], moveHistory: [MoveModel]) -> Bool {
        guard case let .king(player) = board[index(forRow: fromRow, col: fromCol)] else {
            return false
        }
        
        /// Check if the king has moved
        let kingPosition = (row: fromRow, col: fromCol)
        let kingPiece = board[index(forRow: fromRow, col: fromCol)]
        if kingPiece.hasMoved(at: kingPosition, moveHistory: moveHistory) {
            return false
        }
        
        /// King must move exactly two squares horizontally.
        if fromRow != toRow || abs(fromCol - toCol) != 2 {
            return false
        }
        
        let isKingSide = toCol > fromCol
        let rookCol = isKingSide ? 7 : 0
        let rookIndex = index(forRow: fromRow, col: rookCol)
        let rook = board[rookIndex]
        
        /// Check if the rook is there and it's the right color
        guard case let .rook(rookPlayer) = rook,
              rookPlayer == player else {
            return false
        }
        
        /// Check if the rook has moved
        let rookPosition = (row: fromRow, col: rookCol)
        if rook.hasMoved(at: rookPosition, moveHistory: moveHistory) {
            return false
        }
        
        guard case let .king(player) = board[index(forRow: fromRow, col: fromCol)],
              !board[index(forRow: fromRow, col: fromCol)].hasMoved else {
            return false
        }
        
        /// King must move exactly two squares horizontally.
        if fromRow != toRow || abs(fromCol - toCol) != 2 {
            return false
        }
        
        guard case let .rook(rookPlayer) = rook,
              rookPlayer == player,
              !rook.hasMoved else {
            return false
        }
        
        /// Check that the path between king and rook is clear.
        let startCol = min(fromCol, rookCol) + 1
        let endCol = max(fromCol, rookCol)
        for col in startCol..<endCol {
            if board[index(forRow: fromRow, col: col)] != .empty {
                return false
            }
        }
        
        let opposingPlayer: PlayerModel = player == .white ? .black : .white
        
        /// Ensure king is not in check and doesn't pass through or land on an attacked square.
        if isSquareAttacked(row: fromRow, col: fromCol, by: opposingPlayer, board: board, moveHistory: moveHistory) {
            return false
        }
        
        let direction = isKingSide ? 1 : -1
        let passCol = fromCol + direction
        if isSquareAttacked(row: fromRow, col: passCol, by: opposingPlayer, board: board, moveHistory: moveHistory) {
            return false
        }
        
        if isSquareAttacked(row: toRow, col: toCol, by: opposingPlayer, board: board, moveHistory: moveHistory) {
            return false
        }
        
        return true
    }
    
    // MARK: - Square Attack Detection
    
    static func isSquareAttacked(row: Int, col: Int, by attackingPlayer: PlayerModel, board: [PieceModel], moveHistory: [MoveModel]) -> Bool {
        /// Iterate through every square to see if any piece of the attacking player can move to (row, col).
        for r in 0..<8 {
            for c in 0..<8 {
                let currentIndex = index(forRow: r, col: c)
                let piece = board[currentIndex]
                if piece != .empty && piece.belongsToPlayer(attackingPlayer) {
                    
                    // For kings, check only nearby squares to avoid recursion.
                    if case .king = piece {
                        let rowDiff = abs(r - row)
                        let colDiff = abs(c - col)
                        if rowDiff <= 1 && colDiff <= 1 {
                            return true
                        }
                        continue
                    }
                    
                    if isValidMove(fromRow: r, fromCol: c, toRow: row, toCol: col, board: board, piece: piece, lastMove: nil, moveHistory: moveHistory) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}
