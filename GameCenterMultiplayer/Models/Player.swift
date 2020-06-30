//
//  Player.swift
//  GameCenterMultiplayer
//
//  Created by Pedro Contine on 29/06/20.
//

import Foundation
import UIKit

struct Player: Codable {
    var displayName: String
    var status: PlayerStatus = .idle
    var life: Float = 100
}

enum PlayerType: String, Codable, CaseIterable {
    case one
    case two
}

extension PlayerType {
    func enemyIndex() -> Int {
        switch self {
        case .one:
            return 1
        case .two:
            return 0
        }
    }
    
    func index() -> Int {
        switch self {
        case .one:
            return 0
        case .two:
            return 1
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .one:
            return .systemBlue
        case .two:
            return .systemRed
        }
    }
}
