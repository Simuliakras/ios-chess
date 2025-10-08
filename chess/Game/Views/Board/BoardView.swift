import SwiftUI

struct BoardView: View {
    @ObservedObject var boardViewModel: BoardViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                squaresGrid(geometry: geometry)
                piecesGrid(geometry: geometry)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.vertical)
    }
    
    private func squaresGrid(geometry: GeometryProxy) -> some View {
        GridView(rows: 8, columns: 8) { row, col in
            let isLightSquare = (row + col) % 2 == 0
            let isSelected = boardViewModel.isCellSelected(row: row, col: col)
            let isValidCaptureSquare = isValidCaptureMove(row: row, col: col)
            let isValidMove = boardViewModel.selectedPieceValidMoves.contains { $0 == (row, col) }
            let displayDot = isValidMove && !isValidCaptureSquare
            let isKingUnderAttack = boardViewModel.isKingInCheck(forPlayer: boardViewModel.currentPlayer)
            let kingPosition = boardViewModel.kingPosition(forPlayer: boardViewModel.currentPlayer)
            let isKingSquare = (row, col) == kingPosition  // ✅ Only highlight if it's the king's square

            SquareView(
                isLightSquare: isLightSquare,
                displayDot: displayDot,
                isSelected: isSelected,
                isValidCaptureSquare: isValidCaptureSquare,
                isKingUnderAttack: isKingUnderAttack,
                isKingSquare: isKingSquare, // ✅ Pass this to SquareView
                row: row,
                col: col
            )
            .frame(width: geometry.size.width / 8, height: geometry.size.height / 8)
            .onTapGesture {
                boardViewModel.selectCell(atRow: row, atCol: col)
            }
        }
    }
    
    private func piecesGrid(geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(0..<8) { row in
                ForEach(0..<8) { col in
                    if let piece = boardViewModel.pieceAt(row: row, col: col), piece != .empty {
                        let isDragged = boardViewModel.isPieceDragged(row: row, col: col)
                        
                        PieceView(
                            piece: piece,
                            geometry: geometry,
                            boardViewModel: boardViewModel,
                            row: row,
                            col: col
                        )
                        .frame(width: geometry.size.width / 8, height: geometry.size.height / 8)
                        .position(
                            x: CGFloat(col) * geometry.size.width / 8 + geometry.size.width / 16,
                            y: CGFloat(row) * geometry.size.height / 8 + geometry.size.height / 16
                        )
                        .zIndex(isDragged ? 1 : 0)
                    }
                }
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
    
    private func isValidCaptureMove(row: Int, col: Int) -> Bool {
        guard
            boardViewModel.selectedPieceValidMoves.contains(where: { $0 == (row, col) }),
            let piece = boardViewModel.pieceAt(row: row, col: col),
            piece != .empty
        else {
            return false
        }
        
        return !piece.belongsToPlayer(boardViewModel.currentPlayer)
    }
}

struct GridView<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content
    
    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<columns, id: \.self) { col in
                        content(row, col)
                    }
                }
            }
        }
    }
}
