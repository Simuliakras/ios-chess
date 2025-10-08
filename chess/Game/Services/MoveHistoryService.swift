//
//  MoveHistoryService.swift
//  chess
//
//  Created by Algirdas Jasaitis on 26/03/2025.
//

import Foundation

class MoveHistoryService {
    private(set) var moves: [MoveModel] = []
    private(set) var capturedPieces: [PieceModel] = []
    
    var lastMove: MoveModel? {
        return moves.last
    }
    
    func recordMove(_ move: MoveModel) {
        moves.append(move)
        if let capturedPiece = move.capturedPiece, capturedPiece != .empty {
            capturedPieces.append(capturedPiece)
        }
    }
    
    
    func clear() {
        moves = []
        capturedPieces = []
    }
}
