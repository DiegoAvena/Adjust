//
//  SharedActions.swift
//  Adjust
//
//  Created by cpsc on 5/2/21.
//

import SpriteKit

class SharedButtonFunctions {
    
    public static func createButtonClickEffect(startingScales: CGSize) -> [SKAction] {
        
        let scaleFactor: CGFloat = 1.15
        var buttonClickAction = [SKAction]()
        buttonClickAction.append(SKAction.scale(to: CGSize(width: startingScales.width * scaleFactor, height: startingScales.height * scaleFactor), duration: 0.15))
        buttonClickAction.append(SKAction.scale(to: startingScales, duration: 0.15))
        return buttonClickAction
        
    }
    
}
