//
//  BoardSetupService.swift
//  chess
//
//  Created by Algirdas Jasaitis on 26/03/2025.
//

import Foundation

struct BoardSetupService {
    static func setupStandardGame() -> (BoardModel, (row: Int, col: Int), (row: Int, col: Int)) {
        var board = BoardModel()
        
        let blackBackRank: [PieceModel] = [
            .rook(.black), .knight(.black), .bishop(.black), .queen(.black),
            .king(.black), .bishop(.black), .knight(.black), .rook(.black)
        ]
        
        let whiteBackRank: [PieceModel] = [
            .rook(.white), .knight(.white), .bishop(.white), .queen(.white),
            .king(.white), .bishop(.white), .knight(.white), .rook(.white)
        ]
        
        // Black back rank (row 0)
        for col in 0..<8 {
            board[0, col] = blackBackRank[col]
        }
        
        // Black pawns (row 1)
        for col in 0..<8 {
            board[1, col] = .pawn(.black)
        }
        
        // White pawns (row 6)
        for col in 0..<8 {
            board[6, col] = .pawn(.white)
        }
        
        // White back rank (row 7)
        for col in 0..<8 {
            board[7, col] = whiteBackRank[col]
        }
        
        return (board, (0, 4), (7, 4))
    }
    
    // For future: methods to setup specific opening positions
    static func setupPosition(fenString: String) -> (BoardModel, (row: Int, col: Int), (row: Int, col: Int)) {
        // Parse FEN notation and set up a specific position
        // This would be useful for opening training
        
        // Placeholder implementation returns standard position
        return setupStandardGame()
    }
}
