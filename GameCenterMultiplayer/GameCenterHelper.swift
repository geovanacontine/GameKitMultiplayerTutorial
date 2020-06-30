//
//  Matchmaking.swift
//  GameCenterMultiplayer
//
//  Created by Pedro Contine on 29/06/20.
//

import Foundation
import GameKit

protocol GameCenterHelperDelegate: class {
    func didChangeAuthStatus(isAuthenticated: Bool)
    func presentGameCenterAuth(viewController: UIViewController?)
    func presentMatchmaking(viewController: UIViewController?)
    func presentGame(match: GKMatch)
}

final class GameCenterHelper: NSObject, GKLocalPlayerListener {
    weak var delegate: GameCenterHelperDelegate?
    
    private let minPlayers: Int = 2
    private let maxPlayers: Int = 3
    private let inviteMessage = "Write your default invite message!"
    
    var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { (gcAuthVC, error) in
            self.delegate?.didChangeAuthStatus(isAuthenticated: self.isAuthenticated)
            
            guard GKLocalPlayer.local.isAuthenticated else {
                self.delegate?.presentGameCenterAuth(viewController: gcAuthVC)
                return
            }

            GKLocalPlayer.local.register(self)
        }
    }
    
    func presentMatchmaker() {
        guard GKLocalPlayer.local.isAuthenticated else {return}
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        request.inviteMessage = inviteMessage
        
        guard let vc = GKMatchmakerViewController(matchRequest: request) else {return}
        vc.matchmakerDelegate = self
        delegate?.presentMatchmaking(viewController: vc)
    }
}


extension GameCenterHelper: GKMatchmakerViewControllerDelegate {
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        delegate?.presentGame(match: match)
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker vc did fail with error: \(error.localizedDescription).")
    }
}
