//
//  GameCenterManager.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import GameKit

struct Role {
    static let player1: UInt32 = 0xFFFF0000
    static let player2: UInt32 = 0x0000FFFF
    static let either: UInt32 = 0xFFFFFFFF
}

final class GameCenterManager: NSObject {
    static let shared = GameCenterManager()
    
    private override init() {
        super.init()
        
        GKLocalPlayer.local.register(self)
    }
    
    weak var viewController: UIViewController?
    
    var currentMatch: GKMatch?
    
    func authenticate(_ completionHandler: (() -> Void)? = nil) {
        if !GKLocalPlayer.local.isAuthenticated {
            GKLocalPlayer.local.authenticateHandler = { [unowned self] authVC, error in
                if let authVC = authVC {
                    self.viewController?.present(authVC, animated: true, completion: nil)
                    return
                }
                if let error = error {
                    self.viewController?.showAlert(title: "Authentication Failed", message: error.localizedDescription)
                    return
                }
                completionHandler?()
            }
        }
        completionHandler?()
    }
    
    func presentMatchmaker() {
        guard GKLocalPlayer.local.isAuthenticated else {
            let alert = UIAlertController(title: "Authentication Failed", message: "Enable Game Center in settings. Run the app again and sign in.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            let settings = UIAlertAction(title: "Settings", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(settings)
            alert.preferredAction = settings
            viewController?.present(alert, animated: true, completion: nil)
            return
        }
        
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.defaultNumberOfPlayers = 2
        request.playerAttributes = Role.either
        request.inviteMessage = "Would you like to play Volley Gold together?"
        request.recipientResponseHandler = { player, response in
            print("recipientResponseHandler")
        }
        
        let vc = GKMatchmakerViewController(matchRequest: request)!
        vc.isHosted = false
        vc.matchmakerDelegate = self
        vc.modalPresentationStyle = .fullScreen
        viewController?.present(vc, animated: true)
    }
    
    func submitScore(score: Int) {
        guard GKLocalPlayer.local.isAuthenticated else {
            return
        }
        
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
                                  leaderboardIDs: ["VolleyGoldBestScore"]) { error in
            print(error.debugDescription)
        }
    }
}

extension GameCenterManager: GKMatchmakerViewControllerDelegate {
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true)
        self.viewController?.showAlert(title: "Match maker failed", message: error.localizedDescription)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        currentMatch = match
        viewController.dismiss(animated: true, completion: nil)
        let vc = OnlineGameViewController(match: match)
        vc.modalPresentationStyle = .fullScreen
        self.viewController?.present(vc, animated: true, completion: nil)
    }
}

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

extension GameCenterManager: GKLocalPlayerListener {
    func player(_ player: GKPlayer, didRequestMatchWithOtherPlayers playersToInvite: [GKPlayer]) {
        print("didRequestMatchWithOtherPlayers")
    }

    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        let matchMakerVC = GKMatchmakerViewController(invite: invite)
        matchMakerVC?.matchmakerDelegate = self
        matchMakerVC?.modalPresentationStyle = .fullScreen
        viewController?.dismiss(animated: false)
        viewController?.present(matchMakerVC!, animated: true)
        print("didAccept")
    }
    
    func player(_ player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        print("didRequestMatchWithRecipients")
    }
}
