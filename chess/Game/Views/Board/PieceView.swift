//
//  PieceView.swift
//  chess
//
//  Created by Algirdas Jasaitis on 20/12/2023.
//

import SwiftUI

struct PieceView: View {
    var piece: PieceModel
    var geometry: GeometryProxy
    var row: Int
    var col: Int
    var boardViewModel: BoardViewModel
    
    @StateObject var pieceViewModel: PieceViewModel

    init(piece: PieceModel, geometry: GeometryProxy, boardViewModel: BoardViewModel, row: Int, col: Int) {
        self.piece = piece
        self.geometry = geometry
        self.boardViewModel = boardViewModel
        self.row = row
        self.col = col
        self._pieceViewModel = StateObject(wrappedValue: PieceViewModel(boardViewModel: boardViewModel, row: row, col: col))
    }

    var body: some View {
        let pieceSize = CGSize(width: geometry.size.width / 8.5, height: geometry.size.height / 8.5)

        ZStack {
            if let imageName = piece.imageName {
                Image(imageName)
                    .resizable()
                    .frame(width: pieceSize.width, height: pieceSize.height)
                    .offset(pieceViewModel.pieceOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                pieceViewModel.handlePieceDragChanged(gesture: value)
                            }
                            .onEnded { value in
                                pieceViewModel.handlePieceDragEnded(gesture: value, geometry: geometry)
                            }
                    )
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            pieceViewModel.handlePieceTap()
                        }
                    )
            }
        }.zIndex(pieceViewModel.isDragging ? 1 : 0)

    }
}
