//
//  GameViewController.swift
//  GameCenterMultiplayer
//
//  Created by Pedro Contine on 29/06/20.
//

import UIKit
import GameKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var player1: UIImageView!
    @IBOutlet weak var progressPlayer1: UIProgressView!
    @IBOutlet weak var player2: UIImageView!
    @IBOutlet weak var progressPlayer2: UIProgressView!
    @IBOutlet weak var buttonAttack: UIButton!
    @IBOutlet weak var labelTime: UILabel!
    
    var match: GKMatch?
    private var timer: Timer!
    
    private var gameModel: GameModel! {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gameModel = GameModel()
        match?.delegate = self
        
        player2.transform = CGAffineTransform(scaleX: -1, y: 1)
        savePlayers()
    }
    
    private func initTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            let player = self.getLocalPlayerType()
            if player == .one, self.gameModel.time >= 1 {
                self.gameModel.time -= 1
                self.sendData()
            }
        })
    }
    
    private func savePlayers() {
        guard let player2Name = match?.players.first?.displayName else { return }
        
        let player1 = Player(displayName: GKLocalPlayer.local.displayName)
        let player2 = Player(displayName: player2Name)
        
        gameModel.players = [player1, player2]
        
        gameModel.players.sort { (player1, player2) -> Bool in
            player1.displayName < player2.displayName
        }
        
        sendData()
    }
    
    private func getLocalPlayerType() -> PlayerType {
        if gameModel.players.first?.displayName == GKLocalPlayer.local.displayName {
            return .one
        } else {
            return .two
        }
    }
    
    private func updateUI() {
        guard gameModel.players.count >= 2 else { return }
        
        labelTime.text = "\(gameModel.time)"
        player1.image = gameModel.players[0].status.image(player: .one)
        progressPlayer1.progress = gameModel.players[0].life / 100.0
        player2.image = gameModel.players[1].status.image(player: .two)
        progressPlayer2.progress = gameModel.players[1].life / 100.0
        
        let player = getLocalPlayerType()
        buttonAttack.backgroundColor = player.color()
    }
    
    @IBAction func buttonAttackPressed() {
        let localPlayer = getLocalPlayerType()
        
        gameModel.players[localPlayer.index()].status = .attack
        gameModel.players[localPlayer.enemyIndex()].status = .hit
        gameModel.players[localPlayer.enemyIndex()].life -= 10
        sendData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.gameModel.players[localPlayer.index()].status = .idle
            self.gameModel.players[localPlayer.enemyIndex()].status = .idle
            self.sendData()
        }
    }
    
    private func sendData() {
        guard let match = match else { return }
        
        do {
            guard let data = gameModel.encode() else { return }
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Send data failed")
        }
    }
}

extension GameViewController: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        guard let model = GameModel.decode(data: data) else { return }
        
        if getLocalPlayerType() == .one, timer == nil {
            self.initTimer()
        }
        
        gameModel = model
    }
}
