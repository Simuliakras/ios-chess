//
//  PieceViewModel.swift
//  chess
//
//  Created by Algirdas Jasaitis on 07/01/2024.
//

import SwiftUI

class PieceViewModel: ObservableObject {
    @Published var pieceOffset: CGSize = .zero
    @Published var isDragging: Bool = false

    private let row: Int
    private let col: Int
    private var boardViewModel: BoardViewModel

    init(boardViewModel: BoardViewModel, row: Int, col: Int) {
        self.boardViewModel = boardViewModel
        self.row = row
        self.col = col
    }

    func handlePieceTap() {
        guard let selectedCell = boardViewModel.selectedCell else {
            withAnimation(.easeInOut(duration: 0.1)) {
                boardViewModel.selectCell(atRow: row, atCol: col)
            }
            return
        }

        if selectedCell == (row, col) {
            withAnimation(.easeInOut(duration: 0.1)) {
                boardViewModel.selectedCell = nil
            }
        } else {
            boardViewModel.movePiece(fromRow: selectedCell.row, fromCol: selectedCell.col, toRow: row, toCol: col)
            boardViewModel.selectedCell = nil
        }
    }

    func handlePieceDragChanged(gesture: DragGesture.Value) {
        guard boardViewModel.selectedCell != nil else {
            withAnimation(.easeInOut(duration: 0.1)) {
                boardViewModel.selectCell(atRow: row, atCol: col)
            }
            return
        }

        pieceOffset = gesture.translation
        isDragging = true

        if boardViewModel.draggedPieceRow == nil || boardViewModel.draggedPieceCol == nil {
            boardViewModel.setDraggedPiece(row: row, col: col)
        }
    }
    
    func handlePieceDragEnded(gesture: DragGesture.Value, geometry: GeometryProxy) {
        withAnimation {
            pieceOffset = .zero
            isDragging = false
        }

        let translation = gesture.translation
        let newPosition = calculateNewPosition(with: translation, geometry: geometry)

        boardViewModel.movePiece(fromRow: row, fromCol: col, toRow: newPosition.row, toCol: newPosition.col)
        boardViewModel.resetDraggedPiece()
    }

    private func calculateNewPosition(with translation: CGSize, geometry: GeometryProxy) -> (row: Int, col: Int) {
        let squareSize = geometry.size.width / 8
        
        // Calculate the current piece's center position
        let currentCenterX = (CGFloat(col) + 0.5) * squareSize
        let currentCenterY = (CGFloat(row) + 0.5) * squareSize
        
        // Calculate the new position with translation
        let newCenterX = currentCenterX + translation.width
        let newCenterY = currentCenterY + translation.height
        
        // Calculate the nearest square by rounding to the closest integer
        let newCol = Int(round(newCenterX / squareSize - 0.5))
        let newRow = Int(round(newCenterY / squareSize - 0.5))
        
        // Ensure the new position is within the board bounds
        let boundedCol = min(max(0, newCol), 7)
        let boundedRow = min(max(0, newRow), 7)
        
        return (boundedRow, boundedCol)
    }
}
