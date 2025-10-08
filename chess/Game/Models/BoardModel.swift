//
//  BoardModel.swift
//  chess
//
//  Created by Algirdas Jasaitis on 22/12/2023.
//

import Foundation

struct BoardModel {
    private(set) var pieces: [PieceModel] = Array(repeating: .empty, count: 64)
    
    init(pieces: [PieceModel] = Array(repeating: .empty, count: 64)) {
        self.pieces = pieces
    }
    
    static func positionIndex(forRow row: Int, col: Int) -> Int {
        return row * 8 + col
    }
    
    static func isValidPosition(row: Int, col: Int) -> Bool {
        return row >= 0 && row < 8 && col >= 0 && col < 8
    }
    
    subscript(row: Int, col: Int) -> PieceModel {
        get {
            guard BoardModel.isValidPosition(row: row, col: col) else { return .empty }
            return pieces[BoardModel.positionIndex(forRow: row, col: col)]
        }
        set {
            guard BoardModel.isValidPosition(row: row, col: col) else { return }
            pieces[BoardModel.positionIndex(forRow: row, col: col)] = newValue
        }
    }
    
    func copy() -> BoardModel {
        return BoardModel(pieces: self.pieces)
    }
}

