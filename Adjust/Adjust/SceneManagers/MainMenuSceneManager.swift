//
//  MainMenuSceneManager.swift
//  Adjust
//
//  Created by cpsc on 4/24/21.
//

import SpriteKit

/*
 
 Manages the main menu scene
 
 */
class MainMenuSceneManager: BaseMenuSceneManager {
    
    override func didMove(to view: SKView) {
        
        Scores.loadScoresIn()
        initializeScene(title: "Adjust!", newGameBtnName: "newGameBtn")
        
    }
    
}
