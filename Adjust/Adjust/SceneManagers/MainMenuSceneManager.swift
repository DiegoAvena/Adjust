//
//  MainMenuSceneManager.swift
//  Adjust
//
//  Created by cpsc on 4/24/21.
//

import SpriteKit

class MainMenuSceneManager: SKScene {

    override func didMove(to view: SKView) {
        
        print("LOADING MAIN MENU")

        //Initialize the gamescene
        let gameTitle = SKLabelNode(fontNamed: "Our-Arcade-Games")
        gameTitle.fontSize = 41
        gameTitle.fontColor = UIColor.red
        gameTitle.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 2)
        gameTitle.text = "ADJUST!"
        self.addChild(gameTitle)
        
    }

    override func update(_ currentTime: TimeInterval) {
        
    }
    
}
