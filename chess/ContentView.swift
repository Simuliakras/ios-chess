//
//  ContentView.swift
//  chess
//
//  Created by Algirdas Jasaitis on 22/12/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var boardViewModel = BoardViewModel()
    
    var body: some View {
        VStack {
            VStack {
                BoardView(boardViewModel: boardViewModel)
                Button("Reset board") {
                    boardViewModel.resetBoard()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
