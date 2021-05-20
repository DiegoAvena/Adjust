//
//  GameOverSceneManager.swift
//  Adjust
//
//  Created by cpsc on 5/7/21.
//

import SpriteKit

/*
 
 Manages the gameover
 scene
 
 */
class GameOverSceneManager: BaseMenuSceneManager {

    override func didMove(to view: SKView) {
        
        initializeScene(title: "Game Over!", newGameBtnName: "retryBtn", fontSize: 45, newHighScore: Scores.saveScore())
        
    }
    
}
