//
//  GameScene.swift
//  Adjust
//
//  Created by cpsc on 4/24/21.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var currentScore: Int = 0
    
    
    private var numberOfPlatformsOnScreenStill = 0
    
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
    
    var currentPlatformThatPlayerNeedsToDodge: PlatformManager?
    
    //difficulty increases
    let platformMovementTimes: [CGFloat] = [3, 2.5, 2, 1.5, 1.15]
    var currentDifficulty = 0
    var platformMovementTime: CGFloat = 3
    let difficultyIncreaseInterval = 10 //increase the difficulty every 10 secs
    let difficultyIncreaseActionTag = "difficultyIncreaseAction" //an ID used to pause or unpause the action
    
    var additionalSlitSpacing: CGFloat = 15
    
    var platformsThatHavePassedPlayerAlready: [String: PlatformManager]!
    
    //ghost power up
    public var ghostPowerUpActive: Bool = false
    let numberOfPlatformsPlayerCanSkipWhileGhostPowerUpIsActive = 4
    var currentNumberOfPlatformsPlayerHasPassedWhileGhostPowerUpWasActive = 0
    
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
        
        self.tryToSpawnSomePlatforms()
        
        var difficultyIncreaseAction: [SKAction] = []
        difficultyIncreaseAction.append(SKAction.wait(forDuration: TimeInterval(difficultyIncreaseInterval)))
        difficultyIncreaseAction.append(SKAction.run {
            
            if ((self.currentDifficulty + 1) < self.platformMovementTimes.count) {
                
                //not yet at max speed:
                self.currentDifficulty+=1
                self.platformMovementTime = self.platformMovementTimes[self.currentDifficulty]
                print("INCREASE DIFFICULTY TO: \(self.currentDifficulty)")
                
            }
            
        })
        
        //will gradually increment the difficulty
        self.run(SKAction.repeatForever(SKAction.sequence(difficultyIncreaseAction)), withKey: difficultyIncreaseActionTag)
        
    }
    
    /*
     
     I would have liked to put this method inside of the
     ghost power up manager but the ghost power up will get destroyed
     with the platform it is on when that platform exits the screen,
     preventing this countdown action from ever completing and keeping
     that power up on for the rest of the game, so I decided to just run
     the countdown right here from within the game manager, and it is called from the
     ghost powerup manager class
     
     */
    private func manageGhostPowerUpActivity() {
        
        if (ghostPowerUpActive) {
            
            if (currentNumberOfPlatformsPlayerHasPassedWhileGhostPowerUpWasActive >= numberOfPlatformsPlayerCanSkipWhileGhostPowerUpIsActive) {
                
                ghostPowerUpActive = false
                currentNumberOfPlatformsPlayerHasPassedWhileGhostPowerUpWasActive = 0
                currentPlatformThatPlayerNeedsToDodge!.toggleGhostMode(on: false)

                /*for platformSpawnedIn in platformsSpawnedInSoFar! {
                    
                    if (!platformSpawnedIn.ghostModeActive) {
                        
                        platformSpawnedIn.toggleGhostMode(on: false)
                        
                    }
                    
                }*/
                
            }
            else {
                
                /*for platformSpawnedIn in platformsSpawnedInSoFar! {
                    
                    if (!platformSpawnedIn.ghostModeActive) {
                        
                        platformSpawnedIn.toggleGhostMode(on: true)
                        
                    }
                    
                } */
                if (!currentPlatformThatPlayerNeedsToDodge!.ghostModeActive) {
                    
                    currentPlatformThatPlayerNeedsToDodge!.toggleGhostMode(on: true)
                    
                }
                
            }
            
            
        }
        
    }
    
    private func pauseGame() {
            
        gameIsPaused = true
        
        //pause all actions:
        /*if let cubeAction = mainCube?.action(forKey: cubeActionTag) {
            
            cubeAction.speed = 0
            
        }*/
        mainCube?.pauseOrResumeCubeMovement(pause: true)
        
        /*for platform in platformsSpawnedInSoFar! {
            
            platform.pauseOrUnpauseAllPlatformMovement(pause: true)
            
        } */
        if (currentPlatformThatPlayerNeedsToDodge != nil) {
            
            currentPlatformThatPlayerNeedsToDodge?.pauseOrUnpauseAllPlatformMovement(pause: true)
            
        }
        
        /*
         
         
         if let platformAction = platform.action(forKey: platformMovementTag) {
             
             if (pause) {
                 
                 platformAction.speed = 0
                 
             }
             else {
                 
                 platformAction.speed = 1
                 
             }
             
         }
         
         */
        //pause difficulty increase action:
        if let difficultyIncreaseAction = self.action(forKey: difficultyIncreaseActionTag) {
            
            difficultyIncreaseAction.speed = 0
            
        }
        
        for (platformID, _) in platformsThatHavePassedPlayerAlready {
            
            platformsThatHavePassedPlayerAlready[platformID]?.pauseOrUnpauseAllPlatformMovement(pause: true)
            
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
        
        if (currentPlatformThatPlayerNeedsToDodge != nil) {
            
            currentPlatformThatPlayerNeedsToDodge!.pauseOrUnpauseAllPlatformMovement(pause: false)
            
        }
        
        for (platformID, _) in platformsThatHavePassedPlayerAlready {
            
            platformsThatHavePassedPlayerAlready[platformID]?.pauseOrUnpauseAllPlatformMovement(pause: false)
            
        }
        
        if let difficultyIncreaseAction = self.action(forKey: difficultyIncreaseActionTag) {
            
            difficultyIncreaseAction.speed = 1
            
        }
        
        /*
        for platform in platformsSpawnedInSoFar! {
            
            platform.pauseOrUnpauseAllPlatformMovement(pause: false)
            
        } */
        
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
        
        if (/*(platformsSpawnedInSoFar!.count == 0) || (platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready)*/(currentPlatformThatPlayerNeedsToDodge == nil) || currentPlatformThatPlayerNeedsToDodge!.passedCubeAlready) {
                        
            let newPlatform = PlatformManager(scene: self, platformMovementTime: platformMovementTime, platformSlitSpacing: (mainCube!.getMainCubeSize().height * 2) + additionalSlitSpacing, xCordAtWhichCubeIsPassed: mainCube!.getMainCubePosition().x + (mainCube!.getMainCubeSize().width / 3.5), platformID: "Platform\(/*platformsSpawnedInSoFar!.count*/numberOfPlatformsOnScreenStill)", canAttemptToSpawnPowerUp: !ghostPowerUpActive)
            
            numberOfPlatformsOnScreenStill+=1
            
            //platformsSpawnedInSoFar!.append(newPlatform)
            currentPlatformThatPlayerNeedsToDodge = newPlatform
            
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
            
            /*if (platformsSpawnedInSoFar!.count > 0) {
                
                if (!platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready) {
                    
                    platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].ManagePlatformScrolling(yTranslation: yTranslation, scene: self)
                    
                }
                
            }*/
            if (currentPlatformThatPlayerNeedsToDodge != nil) {
                
                if (!currentPlatformThatPlayerNeedsToDodge!.passedCubeAlready) {
                    
                    currentPlatformThatPlayerNeedsToDodge?.ManagePlatformScrolling(yTranslation: yTranslation, scene: self)
                    
                }
                
            }

        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!gameIsEnding) {
            
            /*if (platformsSpawnedInSoFar!.count > 0) {
                
                if (!platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready) {
                    
                    platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].makePlatformsRubberbandBack()
                    
                }
                
            } */
            if (currentPlatformThatPlayerNeedsToDodge != nil) {
                
                if (!currentPlatformThatPlayerNeedsToDodge!.passedCubeAlready) {
                    
                    currentPlatformThatPlayerNeedsToDodge!.makePlatformsRubberbandBack()
                    
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
            
            /*
             
             NOTE TO SELF:
             
             This was causing a bug where the collision between a platform the
             player still needs to dodge and the player is treated as if it were a
             collision between a platform the player already dodged and the player
             
             I might want to fix this otherwise the game might crash due to integer overflow if the player somehow makes it very far into the game, like to
             the point where they score more than 2,147,483,648...but then again, this
             might be extremely unlikely so I might just let it go for the time being
             
             */
            /*if (numberOfPlatformsOnScreenStill > 0) {
                
                numberOfPlatformsOnScreenStill-=1
                
            }*/
            
            platformsThatHavePassedPlayerAlready.removeValue(forKey: IDOfPlatformToRemove)
            
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if (!gameIsEnding) {
            
            manageGhostPowerUpActivity()
            
            if (/*platformsSpawnedInSoFar!.count > 0*/currentPlatformThatPlayerNeedsToDodge != nil) {
                
                if (/*!platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].passedCubeAlready*/!currentPlatformThatPlayerNeedsToDodge!.passedCubeAlready) {
                    
                    if (/*platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].checkForWhenThisPlatformPassesMainCube()*/currentPlatformThatPlayerNeedsToDodge!.checkForWhenThisPlatformPassesMainCube()) {
                        
                        /*
     
                            place this into the platforms that player has dodged dictionary
                            so that if it collides with the cube on retract, the collision
                            is not counted
                         
                        */
                        //platformsThatHavePassedPlayerAlready[platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].getPlatformID()] = platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1]
                        platformsThatHavePassedPlayerAlready[currentPlatformThatPlayerNeedsToDodge!.getPlatformID()] = currentPlatformThatPlayerNeedsToDodge!
                        
                        removeInActivePlatformsFromDodgedPlatformsCollection()
                        
                        if (ghostPowerUpActive) {
                            
                            currentNumberOfPlatformsPlayerHasPassedWhileGhostPowerUpWasActive+=1
                            
                        }
                        
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
            
            if ((firstBody.categoryBitMask & PhysicsCategories.mainCube) == 1) {
                
                //the main cube has hit something:
                if (secondBody.categoryBitMask == PhysicsCategories.platforms) {
                    
                    //print("Hit a platform")
                    if ((platformsThatHavePassedPlayerAlready[(secondBody.node!.name)!] != nil) || ghostPowerUpActive) {
                        
                        //the cube hit a platform that it already passed, or ghost power up is active
                        return
                        
                    }
                    
                    //the main cube hit a platform and should explode:
                    //print("main cube hit platform and should explode")
                    gameIsEnding = true
                    
                    //pause all platform movement:
                    /*for platform in platformsSpawnedInSoFar! {
                        
                        platform.pauseOrUnpauseAllPlatformMovement(pause: true)
                        
                    } */
                    if (currentPlatformThatPlayerNeedsToDodge != nil) {
                        
                        currentPlatformThatPlayerNeedsToDodge!.pauseOrUnpauseAllPlatformMovement(pause: true)
                        
                    }
                    
                    for (platformID, _) in platformsThatHavePassedPlayerAlready {
                        
                        platformsThatHavePassedPlayerAlready[platformID]?.pauseOrUnpauseAllPlatformMovement(pause: true)
                        
                    }
                    
                    mainCube?.doDeath()
                    
                }
                else if (secondBody.categoryBitMask == PhysicsCategories.powerUps) {
                    
                    //platformsSpawnedInSoFar![platformsSpawnedInSoFar!.count - 1].spawnedPowerUp!.doPowerUpFunctionality(gameManager: self)
                
                    currentPlatformThatPlayerNeedsToDodge!.spawnedPowerUp!.doPowerUpFunctionality(gameManager: self)
                    
                }
            
            }
            
        }
        
    }
    
}
