//
//  GameScene.swift
//  Adjust
//
//  Created by cpsc on 4/24/21.
//

import SpriteKit

class GameScene: SKScene {
    
    private var cubeSpeed: CGFloat = 2.5
    private var currentScore: Int = 0
    
    private var scoreLabel: SKLabelNode!
    
    private var pauseGameButton: SKSpriteNode!
    private var quitGameButton: SKSpriteNode!
    
    private var pauseScreenLabel: SKLabelNode?
    private var pauseScreenResumeButton: SKSpriteNode?
    private var pauseScreenBG: SKSpriteNode?
    
    private let cubeActionTag = "cubeMovement"
    
    private var mainCube: SKSpriteNode?
    
    var currentColorVal: CGFloat = 0.45
    
    private var gameIsPaused = false
    
    //prevents spamming of buttons
    private var doingAButtonFunctionAlready: Bool = false
    
    let textColor: CGColor = CGColor(red: 173 / 255, green: 5 / 255, blue: 5 / 255, alpha: 1)
    
    var platformsSpawnedInSoFar: [PlatformManager]?
    var platformMovementTime: CGFloat = 3.25
    var additionalSlitSpacing: CGFloat = 15
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor(cgColor: CGColor(red: currentColorVal, green: currentColorVal, blue: currentColorVal, alpha: 1))
        
        //load the main cube in:
        mainCube = SKSpriteNode(imageNamed: "mainPlayer")
        mainCube?.scale(to: CGSize(width: (mainCube?.size.width)! * 0.94, height: (mainCube?.size.height)! * 0.94))
        mainCube?.position = CGPoint(x: self.frame.size.width / 2.5, y: self.frame.size.height  / 2)
        
        mainCube?.run(SKAction.repeatForever(SKAction.sequence(formUpAndDownAction(startingXCord: (mainCube?.position.x)!, cubeHeight: (mainCube?.size.height)!))), withKey: cubeActionTag)
        self.addChild(mainCube!)
                
        scoreLabel = SKLabelNode(fontNamed: "Our-Arcade-Games")
        scoreLabel.fontSize = 20
        scoreLabel.color = UIColor(cgColor: textColor)
        scoreLabel.position = CGPoint(x: self.frame.size.width / 5.5, y: self.frame.size.height - (self.frame.size.height / 11))
        scoreLabel.text = "Score: \(currentScore)"
        scoreLabel.zPosition = 10
        self.addChild(scoreLabel)
        
        pauseGameButton = SKSpriteNode(imageNamed: "pauseBtn")
        pauseGameButton.name = "pauseGameButton"
        pauseGameButton.scale(to: CGSize(width: pauseGameButton.size.width * 0.8, height: pauseGameButton.size.height * 0.8))
        pauseGameButton.position = CGPoint(x: self.frame.size.width - (pauseGameButton.size.width * 2), y: scoreLabel.position.y)
        pauseGameButton.zPosition = 10
        self.addChild(pauseGameButton)
        
        quitGameButton = SKSpriteNode(imageNamed: "quitBtn")
        quitGameButton.name = "quitGameButton"
        quitGameButton.scale(to: CGSize(width: quitGameButton.size.width * 0.8, height: quitGameButton.size.height * 0.8))
        quitGameButton.position = CGPoint(x: self.frame.size.width - (quitGameButton.size.width - (quitGameButton.size.width / 4)), y: scoreLabel.position.y)
        quitGameButton.zPosition = 10
        self.addChild(quitGameButton)
        
        platformsSpawnedInSoFar = [PlatformManager]()
        self.tryToSpawnSomePlatforms()
        
    }

    private func formUpAndDownAction(startingXCord: CGFloat, cubeHeight: CGFloat) -> [SKAction] {
        
        var moveUpAndDownAction = [SKAction]()
        moveUpAndDownAction.append(SKAction.move(to: CGPoint(x: startingXCord , y: cubeHeight / 2), duration: TimeInterval(cubeSpeed)))
        moveUpAndDownAction.append(SKAction.move(to: CGPoint(x: startingXCord, y: self.frame.size.height - (cubeHeight / 2)), duration: TimeInterval(cubeSpeed)))
        return moveUpAndDownAction
        
    }
    
    private func pauseGame() {
            
        gameIsPaused = true
        
        //pause all actions:
        if let cubeAction = mainCube?.action(forKey: cubeActionTag) {
            
            cubeAction.speed = 0
            
        }
        
        for platform in platformsSpawnedInSoFar! {
            
            platform.pauseOrUnpauseAllPlatformMovement(pause: true)
            
        }
        
        pauseScreenLabel = SKLabelNode(fontNamed: "Our-Arcade-Games")
        pauseScreenLabel?.fontSize = 40
        pauseScreenLabel?.color = UIColor(cgColor: textColor)
        pauseScreenLabel?.text = "PAUSED"
        pauseScreenLabel?.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 1.45)
        pauseScreenLabel?.zPosition = 20
        self.addChild(pauseScreenLabel!)
        
        pauseScreenResumeButton = SKSpriteNode(imageNamed: "resumeBtn")
        pauseScreenResumeButton?.name = "resumeGameButton"
        pauseScreenResumeButton?.position = CGPoint(x: self.frame.size.width / 2, y: (self.frame.size.height / 2) - 60)
        pauseScreenResumeButton?.zPosition = 20
        pauseScreenResumeButton?.scale(to: CGSize(width: (pauseScreenResumeButton?.size.width)! * 0.8, height: (pauseScreenResumeButton?.size.height)! * 0.8))
        self.addChild(pauseScreenResumeButton!)
        
        pauseScreenBG = SKSpriteNode(imageNamed: "platform")
        pauseScreenBG?.scale(to: CGSize(width: (pauseScreenBG?.size.width)! * 50, height: (pauseScreenBG?.size.height)! * 20))
        pauseScreenBG?.colorBlendFactor = 1
        pauseScreenBG?.color = UIColor(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 0.5))
        pauseScreenBG?.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        pauseScreenBG?.zPosition = 19
        self.addChild(pauseScreenBG!)
        
        doingAButtonFunctionAlready = false

    }
    
    private func resumeGame() {
        
        pauseScreenLabel?.removeFromParent()
        pauseScreenBG?.removeFromParent()
        pauseScreenResumeButton?.removeFromParent()
        
        gameIsPaused = false
        
        //resume all skactions:
        if let cubeAction = mainCube?.action(forKey: cubeActionTag) {
            
            cubeAction.speed = 1
            
        }
        
        for platform in platformsSpawnedInSoFar! {
            
            platform.pauseOrUnpauseAllPlatformMovement(pause: false)
            
        }
        
        doingAButtonFunctionAlready = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (doingAButtonFunctionAlready) {
            
            return
            
        }
        
        let touch = touches.first
        
        if let touchLocation = touch?.location(in: self) {
            
            let nodesArray = self.nodes(at: touchLocation)
            
            if (!gameIsPaused) {
                
                if nodesArray.first?.name == "pauseGameButton" {
                    
                    doingAButtonFunctionAlready = true
                    self.run(SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false))
                    //transition to the game scene:
                    nodesArray.first?.run(SKAction.sequence(SharedButtonFunctions.createButtonClickEffect(startingScales: pauseGameButton!.size)), completion: {
                        
                        self.pauseGame()
                         
                    })
                    
                }
                else if nodesArray.first?.name == "quitGameButton" {
                    
                    doingAButtonFunctionAlready = true
                    self.run(SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false))
                    
                    //transition back to the main menu:
                    nodesArray.first?.run(SKAction.sequence(SharedButtonFunctions.createButtonClickEffect(startingScales: quitGameButton!.size)), completion: {
                        
                        let transition = SKTransition.flipVertical(withDuration: 0.5)
                        
                        if let mainMenuScene = MainMenuSceneManager(fileNamed: "MainMenu") {
                            
                            self.view?.presentScene(mainMenuScene, transition: transition)

                        }
                         
                    })
                    
                }
                
            }
            else {
                
                if nodesArray.first?.name == "resumeGameButton" {
                    
                    doingAButtonFunctionAlready = true
                    self.run(SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false))
                    
                    //transition back to the main menu:
                    nodesArray.first?.run(SKAction.sequence(SharedButtonFunctions.createButtonClickEffect(startingScales: pauseScreenResumeButton!.size)), completion: {
                        
                        print("RESUME GAME")
                        self.resumeGame()
                         
                    })
                    
                }
                
            }
            
        }
        
    }
    
    private func tryToSpawnSomePlatforms() {
        
        if ((platformsSpawnedInSoFar!.count == 0) || (platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready)) {
            
            let newPlatform = PlatformManager(scene: self, platformMovementTime: platformMovementTime, platformSlitSpacing: (mainCube!.size.height * 2) + additionalSlitSpacing, xCordAtWhichCubeIsPassed: mainCube!.position.x + (mainCube!.size.width / 2))
            platformsSpawnedInSoFar!.append(newPlatform)
            
        }
        
    }
    
    /*
     
     Used for the swiping up and down of the vertical
     platforms
     
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        let positionInScene = touch?.location(in: self)
        let previousPosition = touch?.previousLocation(in: self)
        let yTranslation = (positionInScene?.y)! - (previousPosition?.y)!
        
        if (platformsSpawnedInSoFar!.count > 0) {
            
            if (!platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready) {
                
                platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].ManagePlatformScrolling(yTranslation: yTranslation, scene: self)
                
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (platformsSpawnedInSoFar!.count > 0) {
            
            if (!platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready) {
                
                platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].makePlatformsRubberbandBack()
                
            }
            
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if (platformsSpawnedInSoFar!.count > 0) {
            
            if (!platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready) {
                
                if (platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].checkForWhenThisPlatformPassesMainCube()) {
                    
                    //increase player score:
                    currentScore += 1
                    scoreLabel.text = "Score: \(currentScore)"
                    self.run(SKAction.playSoundFileNamed("scoreSound", waitForCompletion: false))
                    
                }
                
            }
            
        }
        
        self.tryToSpawnSomePlatforms()
        
    }
    
}
