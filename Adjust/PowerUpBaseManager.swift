//
//  PowerUpBaseManager.swift
//  Adjust
//
//  Created by cpsc on 5/10/21.
//

import SpriteKit

class PowerUpBaseManager {
    
    var thePowerUp: SKSpriteNode
    var parentNode: SKNode
    let horizontalBobbleActionSpeed: CGFloat = 0.1
    let horizontalBobbleActionKey = "powerUpAction"
    
    init(parentNode: SKSpriteNode, upperBound: CGFloat, lowerBound: CGFloat, powerUpName: String, heightRescaleFactor: CGFloat) {
        
        thePowerUp = SKSpriteNode(imageNamed: powerUpName)
        thePowerUp.scale(to: CGSize(width: thePowerUp.size.width / 1.2, height: ((thePowerUp.size.height / heightRescaleFactor) / 1.2)))
        thePowerUp.zPosition = 1
        let finalUpperBound = upperBound - ((thePowerUp.size.height / heightRescaleFactor) / 2)
        let finalLowerBound = lowerBound + ((thePowerUp.size.height / heightRescaleFactor) / 2)
        
        thePowerUp.position = CGPoint(x: (-parentNode.size.width / 2) - thePowerUp.size.width / 2, y: CGFloat.random(in: finalUpperBound...finalLowerBound))
        
        self.parentNode = parentNode
        self.parentNode.addChild(thePowerUp)
        
        thePowerUp.run(SKAction.repeatForever(SKAction.sequence(makeHorizontalBobbleAction())), withKey: horizontalBobbleActionKey)
        
    }
    
    func doPowerUpFunctionality() {
        //override this with the correct power up behavior
    }
    
    private func makeHorizontalBobbleAction() -> [SKAction] {
        
        var horizontalBobbleAction: [SKAction] = []
        horizontalBobbleAction.append(SKAction.moveBy(x: -6.5, y: 0, duration: TimeInterval(horizontalBobbleActionSpeed)))
        horizontalBobbleAction.append(SKAction.moveBy(x: 6.5, y: 0, duration: TimeInterval(horizontalBobbleActionSpeed)))
        return horizontalBobbleAction
    
    }
    
    public func pauseOrUnPausePowerUp(pause: Bool) {
    
        if let powerUpAction = thePowerUp.action(forKey: horizontalBobbleActionKey) {
             
            if (pause) {
                
                powerUpAction.speed = 0
                
            }
            else {
                
                powerUpAction.speed = 1
                
            }
            
        }
        
    }
    
}
