//
//  BoardViewModel.swift
//  chess
//
//  Created by Algirdas Jasaitis on 19/12/2023.
//

import Foundation
import Combine

class BoardViewModel: ObservableObject {
    @Published var draggedPieceRow: Int?
    @Published var draggedPieceCol: Int?
    @Published var selectedCell: (row: Int, col: Int)? = nil
    @Published var selectedPieceValidMoves: [(Int, Int)] = []
    
    @Published var gameState: GameStateModel = .active
    @Published var currentPlayer: PlayerModel = .white
    
    private var chessViewModel: ChessViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(chessViewModel: ChessViewModel = ChessViewModel()) {
        self.chessViewModel = chessViewModel
        setupBindings()
    }
    
    private func setupBindings() {
        chessViewModel.$gameState
            .assign(to: \.gameState, on: self)
            .store(in: &cancellables)
        
        chessViewModel.$currentPlayer
            .assign(to: \.currentPlayer, on: self)
            .store(in: &cancellables)
    }
    
    func resetDraggedPiece() {
        draggedPieceRow = nil
        draggedPieceCol = nil
        selectedPieceValidMoves = []
    }
    
    func setDraggedPiece(row: Int, col: Int) {
        guard let piece = pieceAt(row: row, col: col),
              piece != .empty,
              piece.belongsToPlayer(currentPlayer) else {
            return
        }
        
        draggedPieceRow = row
        draggedPieceCol = col
        
        getValidMoves(forPieceAtRow: row, col: col)
    }
    
    func isPieceDragged(row: Int, col: Int) -> Bool {
        return row == draggedPieceRow && col == draggedPieceCol
    }
    
    func resetBoard() {
        chessViewModel.newGame()
        selectedPieceValidMoves = []
        selectedCell = nil
    }
    
    func pieceAt(row: Int, col: Int) -> PieceModel? {
        return chessViewModel.pieceAt(row: row, col: col)
    }
    
    func movePiece(fromRow: Int, fromCol: Int, toRow: Int, toCol: Int) {
        let moveSuccessful = chessViewModel.movePiece(fromRow: fromRow, fromCol: fromCol, toRow: toRow, toCol: toCol)
        
        if moveSuccessful {
            selectedPieceValidMoves = []
            selectedCell = nil
        }
    }
    
    func selectCell(atRow row: Int, atCol col: Int) {
        if let selectedCell = selectedCell {
            if selectedPieceValidMoves.contains(where: { $0.0 == row && $0.1 == col }) {
                movePiece(fromRow: selectedCell.row, fromCol: selectedCell.col, toRow: row, toCol: col)
                self.selectedCell = nil
                selectedPieceValidMoves = []
                return
            }
            
            if row == selectedCell.row && col == selectedCell.col {
                self.selectedCell = nil
                selectedPieceValidMoves = []
                return
            }
            
            if let piece = pieceAt(row: row, col: col),
               piece != .empty &&
               piece.belongsToPlayer(currentPlayer) {
                self.selectedCell = (row, col)
                getValidMoves(forPieceAtRow: row, col: col)
                return
            }
            
            self.selectedCell = nil
            selectedPieceValidMoves = []
            return
        }
        
        guard let piece = pieceAt(row: row, col: col),
              piece != .empty,
              piece.belongsToPlayer(currentPlayer),
              gameState == .active || gameState == .check else {
            self.selectedCell = nil
            selectedPieceValidMoves = []
            return
        }
        
        self.selectedCell = (row, col)
        getValidMoves(forPieceAtRow: row, col: col)
    }
    
    func isCellSelected(row: Int, col: Int) -> Bool {
        if let selectedCell = selectedCell {
            return selectedCell == (row, col)
        }
        return false
    }
    
    func isValidMoveCell(row: Int, col: Int) -> Bool {
        return selectedPieceValidMoves.contains { $0 == (row, col) }
    }
    
    func getValidMoves(forPieceAtRow row: Int, col: Int) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            var validSquares: [(Int, Int)] = []
            
            if let piece = self.pieceAt(row: row, col: col),
               piece != .empty,
               piece.belongsToPlayer(self.currentPlayer) {
                
                for targetRow in 0..<8 {
                    for targetCol in 0..<8 {
                        if self.chessViewModel.canMovePiece(fromRow: row, fromCol: col, toRow: targetRow, toCol: targetCol) {
                            validSquares.append((targetRow, targetCol))
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.selectedPieceValidMoves = validSquares
            }
        }
    }
    
    func isKingInCheck(forPlayer player: PlayerModel) -> Bool {
        return gameState == .check && currentPlayer == player
    }
    
    func isGameOver() -> Bool {
        return gameState == .checkmate || gameState == .stalemate || gameState == .draw
    }
    
    var moveHistory: [MoveModel] {
        return chessViewModel.moveHistory
    }
    
    var capturedPieces: [PieceModel] {
        return chessViewModel.capturedPieces
    }
    
    func kingPosition(forPlayer player: PlayerModel) -> (Int, Int) {
        return player == .white ? chessViewModel.whiteKingPosition : chessViewModel.blackKingPosition
    }
}
