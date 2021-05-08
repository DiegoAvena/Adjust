//
//  GameScene.swift
//  Adjust
//
//  Created by cpsc on 4/24/21.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var currentScore: Int = 0
    
    private var gameIsEnding = false
    private var loadingGameOverSceneAlready = false
    
    private var scoreLabel: SKLabelNode!
    
    private var pauseGameButton: SKSpriteNode!
    private var quitGameButton: SKSpriteNode!
    
    private var pauseScreenLabel: SKLabelNode?
    private var pauseScreenResumeButton: SKSpriteNode?
    private var pauseScreenBG: SKSpriteNode?
    
    private var mainCube: MainCubeManager?
    
    var currentColorVal: CGFloat = 0.45
    
    private var gameIsPaused = false
    
    //prevents spamming of buttons
    private var doingAButtonFunctionAlready: Bool = false
    
    let textColor: CGColor = CGColor(red: 173 / 255, green: 5 / 255, blue: 5 / 255, alpha: 1)
    
    var platformsSpawnedInSoFar: [PlatformManager]?
    var platformMovementTime: CGFloat = 3.25
    var additionalSlitSpacing: CGFloat = 15
    
    var platformsThatHavePassedPlayerAlready: [String: PlatformManager]!
    
    override func didMove(to view: SKView) {
        
        platformsThatHavePassedPlayerAlready = [:]
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor(cgColor: CGColor(red: currentColorVal, green: currentColorVal, blue: currentColorVal, alpha: 1))
        
        //load the main cube in:
        mainCube = MainCubeManager(scene: self)
        
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

    private func pauseGame() {
            
        gameIsPaused = true
        
        //pause all actions:
        /*if let cubeAction = mainCube?.action(forKey: cubeActionTag) {
            
            cubeAction.speed = 0
            
        }*/
        mainCube?.pauseOrResumeCubeMovement(pause: true)
        
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
        mainCube?.pauseOrResumeCubeMovement(pause: false)
        
        for platform in platformsSpawnedInSoFar! {
            
            platform.pauseOrUnpauseAllPlatformMovement(pause: false)
            
        }
        
        doingAButtonFunctionAlready = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (doingAButtonFunctionAlready || gameIsEnding) {
            
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
                    nodesArray.first?.run(SKAction.sequence(SharedFunctions.createButtonClickEffect(startingScales: pauseGameButton!.size)), completion: {
                        
                        self.pauseGame()
                         
                    })
                    
                }
                else if nodesArray.first?.name == "quitGameButton" {
                    
                    doingAButtonFunctionAlready = true
                    self.run(SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false))
                    
                    //transition back to the main menu:
                    nodesArray.first?.run(SKAction.sequence(SharedFunctions.createButtonClickEffect(startingScales: quitGameButton!.size)), completion: {
                        
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
                    nodesArray.first?.run(SKAction.sequence(SharedFunctions.createButtonClickEffect(startingScales: pauseScreenResumeButton!.size)), completion: {
                        
                        print("RESUME GAME")
                        self.resumeGame()
                         
                    })
                    
                }
                
            }
            
        }
        
    }
    
    private func tryToSpawnSomePlatforms() {
        
        if ((platformsSpawnedInSoFar!.count == 0) || (platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready)) {
            
            let newPlatform = PlatformManager(scene: self, platformMovementTime: platformMovementTime, platformSlitSpacing: (mainCube!.getMainCubeSize().height * 2) + additionalSlitSpacing, xCordAtWhichCubeIsPassed: mainCube!.getMainCubePosition().x + (mainCube!.getMainCubeSize().width / 3.5), platformID: "Platform\(platformsSpawnedInSoFar!.count)")
            
            platformsSpawnedInSoFar!.append(newPlatform)
            
        }
        
    }
    
    /*
     
     Used for the swiping up and down of the vertical
     platforms
     
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!gameIsEnding) {
            
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
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!gameIsEnding) {
            
            if (platformsSpawnedInSoFar!.count > 0) {
                
                if (!platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready) {
                    
                    platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].makePlatformsRubberbandBack()
                    
                }
                
            }
            
        }
        
    }
    
    private func removeInActivePlatformsFromDodgedPlatformsCollection() {
        
        var IDsOfPlatformsToRemove: [String] = []
        for (platformID, platformManager) in platformsThatHavePassedPlayerAlready {
            
            if (platformManager.offTheScreenAlready) {
                
                IDsOfPlatformsToRemove.append(platformID)
                
            }
            
        }
        
        for IDOfPlatformToRemove in IDsOfPlatformsToRemove {
            
            platformsThatHavePassedPlayerAlready.removeValue(forKey: IDOfPlatformToRemove)
            
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if (!gameIsEnding) {
            
            if (platformsSpawnedInSoFar!.count > 0) {
                
                if (!platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready) {
                    
                    if (platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].checkForWhenThisPlatformPassesMainCube()) {
                        
                        /*
     
                            place this into the platforms that player has dodged dictionary
                            so that if it collides with the cube on retract, the collision
                            is not counted
                         
                        */
                        platformsThatHavePassedPlayerAlready[platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].getPlatformID()] = platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1]
                        
                        removeInActivePlatformsFromDodgedPlatformsCollection()
                        
                        //increase player score:
                        currentScore += 1
                        scoreLabel.text = "Score: \(currentScore)"
                        self.run(SKAction.playSoundFileNamed("scoreSound", waitForCompletion: false))
                        
                    }
                    
                }
                
            }
            
            self.tryToSpawnSomePlatforms()
            
        }
        else if (mainCube!.isDead && !loadingGameOverSceneAlready) {
            
            //start transitioning to game over scene:
            print("load game over scene")
            let transition = SKTransition.flipVertical(withDuration: 0.5)
            if let gameOverScene = GameOverSceneManager(fileNamed: "GameOverScene") {
                
                Scores.recentScore = currentScore
                self.view?.presentScene(gameOverScene, transition: transition)
                loadingGameOverSceneAlready = true
                
            }
            
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        if (!gameIsEnding) {
            
            var firstBody: SKPhysicsBody //will store the potential main cube
            var secondBody: SKPhysicsBody //will store the potential platform or powerup hit
            
            if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
                
                firstBody = contact.bodyA
                secondBody = contact.bodyB
                
            }
            else {
                
                firstBody = contact.bodyB
                secondBody = contact.bodyA
                
            }
            
            if ((firstBody.categoryBitMask & PhysicsCategories.mainCube) != 0) {
                
                //the main cube has hit something:
                if ((secondBody.categoryBitMask & PhysicsCategories.platforms) != 0) {
                    
                    if (platformsThatHavePassedPlayerAlready[(secondBody.node!.name)!] != nil) {
                        
                        //the cube hit a platform that it already passed
                        return
                        
                    }
                    
                    //the main cube hit a platform and should explode:
                    print("main cube hit platform and should explode")
                    gameIsEnding = true
                    
                    //pause all platform movement:
                    for platform in platformsSpawnedInSoFar! {
                        
                        platform.pauseOrUnpauseAllPlatformMovement(pause: true)
                        
                    }
                    
                    mainCube?.doDeath()
                    
                }
                else if ((secondBody.categoryBitMask & PhysicsCategories.powerUps) != 0) {
                    
                    print("Main cube hit a power up!")
                    
                }
            
            }
            
        }
        
    }
    
}
