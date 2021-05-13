//
//  difficultyResetPowerUpManager.swift
//  Adjust
//
//  Created by cpsc on 5/12/21.
//

import SpriteKit

class DifficultyResetPowerUpManager: PowerUpBaseManager {
    
    init(parentNode: SKSpriteNode, upperBound: CGFloat, lowerBound: CGFloat, heightRescaleFactor: CGFloat) {
        
        super.init(parentNode: parentNode, upperBound: upperBound, lowerBound: lowerBound, powerUpName: "resetPowerUp", heightRescaleFactor: heightRescaleFactor)
        
        atlasName = "resetPowerUpCollect.atlas"
        collectionSoundName = "collectingDifficultyResetPowerUp.wav"
        framesName = "resetCollect"
        
    }
    
    override public func doPowerUpFunctionality(gameManager: GameScene) {
        
        super.doPowerUpFunctionality(gameManager: gameManager)
        
    }
    
}
