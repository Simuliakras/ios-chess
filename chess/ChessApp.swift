//
//  chessApp.swift
//  chess
//
//  Created by Algirdas Jasaitis on 18/12/2023.
//

import SwiftUI

@main
struct ChessApp: App {
    let boardViewModel = BoardViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(boardViewModel: boardViewModel)
        }
    }
}

