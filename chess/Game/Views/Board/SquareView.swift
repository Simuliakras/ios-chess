import SwiftUI

struct SquareView: View {
    let isLightSquare: Bool
    let displayDot: Bool
    let isSelected: Bool
    let isValidCaptureSquare: Bool
    let isKingUnderAttack: Bool
    let isKingSquare: Bool
    let row: Int
    let col: Int
    
    private struct ChessColors {
        static let lightSquare = Color(red: 204/255, green: 183/255, blue: 174/255)
        static let darkSquare = Color(red: 112/255, green: 102/255, blue: 119/255)
    }
    
    private var squareColor: Color {
        return isLightSquare ? ChessColors.lightSquare : ChessColors.darkSquare
    }
    
    @ViewBuilder
    private var captureOverlay: some View {
        if isSelected {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        if isValidCaptureSquare || (isKingUnderAttack && isKingSquare) {
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.3), Color.red.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var textColor: Color {
        isLightSquare ? .black : .white
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                squareColor
                captureOverlay
                
                if displayDot {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(
                            width: min(geometry.size.width, geometry.size.height) * 0.25,
                            height: min(geometry.size.width, geometry.size.height) * 0.25
                        )
                }
                
                VStack {
                    HStack {
                        if col == 0 {
                            Text("\(8 - row)")
                                .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.15))
                                .foregroundColor(textColor)
                                .padding(2)
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        if row == 7 {
                            Text("\(Character(UnicodeScalar(97 + col)!))")
                                .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.15))
                                .foregroundColor(textColor)
                                .padding(1)
                        }
                    }
                }
            }
        }
    }
}
