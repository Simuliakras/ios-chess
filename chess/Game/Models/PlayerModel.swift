//
//  PlayerModel.swift
//  chess
//
//  Created by Algirdas Jasaitis on 22/12/2023.
//

import Foundation

enum PlayerModel {
    case white
    case black
    
    var next: PlayerModel {
        return self == .white ? .black : .white
    }
    
    var opponent: PlayerModel {
        return next
    }
}
