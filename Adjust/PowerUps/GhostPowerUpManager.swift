//
//  ghostPowerUpManager.swift
//  Adjust
//
//  Created by cpsc on 5/12/21.
//

import SpriteKit

class GhostPowerUpManager: PowerUpBaseManager {
    
    private var gameManager: GameScene!
    
    init(parentNode: SKSpriteNode, upperBound: CGFloat, lowerBound: CGFloat, heightRescaleFactor: CGFloat) {
        
        super.init(parentNode: parentNode, upperBound: upperBound, lowerBound: lowerBound, powerUpName: "ghostPowerUp",heightRescaleFactor: heightRescaleFactor)
        
        atlasName = "ghostPowerUpCollect.atlas"
        collectionSoundName = "collectingGhostPowerUpSound.wav"
        framesName = "ghostCollect"

    }
    
    override public func doPowerUpFunctionality(gameManager: GameScene) {
        
        gameManager.ghostPowerUpActive = true
        super.doPowerUpFunctionality(gameManager: gameManager)
        
    }
    
}
