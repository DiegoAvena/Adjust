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
    
    private var needToShowGameControlsToPlayer = true
    
    //prevents spamming of buttons
    private var doingAButtonFunctionAlready: Bool = false
    
    let textColor: CGColor = CGColor(red: 173 / 255, green: 5 / 255, blue: 5 / 255, alpha: 1)
    
    var currentPlatformThatPlayerNeedsToDodge: PlatformManager?
    
    //difficulty increases
    var platformMovementTime: CGFloat = 3
    let difficultyIncreaseInterval = 10 //increase the difficulty every 10 secs
    let difficultyIncreaseActionTag = "difficultyIncreaseAction" //an ID used to pause or unpause the action
    
    var additionalSlitSpacing: CGFloat = 15
    
    var platformsThatHavePassedPlayerAlready: [String: PlatformManager]!
    
    //ghost power up
    public var ghostPowerUpActive: Bool = false
    let numberOfPlatformsPlayerCanSkipWhileGhostPowerUpIsActive = 4
    var currentNumberOfPlatformsPlayerHasPassedWhileGhostPowerUpWasActive = 0
    
    //help screen UI:
    var swipeUpArrow: SKSpriteNode!
    var swipeDownArrow: SKSpriteNode!
    var swipeLabels: [SKLabelNode]!
    var howToStartGameLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        resetDifficulty()
        
        platformsThatHavePassedPlayerAlready = [:]
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor(cgColor: DifficultyColors.getBackgroundColor())
        
        //load the main cube in:
        mainCube = MainCubeManager(scene: self)
        
        scoreLabel = SKLabelNode(fontNamed: "Our-Arcade-Games")
        scoreLabel.fontSize = 20
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        scoreLabel.color = UIColor(cgColor: textColor)
        scoreLabel.position = CGPoint(x: self.frame.size.width / 20.5, y: self.frame.size.height - (self.frame.size.height / 9.25))
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
        
        self.platformMovementTime = DifficultyScales.platformMovementTimes[DifficultyScales.currentDifficulty]
        
        self.tryToSpawnSomePlatforms()
        
        /*
         
         give a grey background to the UI on top
         so its easier to distinguish
         
         */
        let UIBackground = SKSpriteNode(imageNamed: "platform")
        UIBackground.scale(to: CGSize(width: UIBackground.size.width * 50, height: UIBackground.size.height * 20))
        
        UIBackground.colorBlendFactor = 1
        UIBackground.color = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 0.15)
        UIBackground.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height + (self.frame.size.height * 5.145))
        UIBackground.zPosition = 9
        self.addChild(UIBackground)
        
        //will gradually increment the difficulty
        self.run(SKAction.repeatForever(SKAction.sequence(formDifficultyIncreaseAction())), withKey: difficultyIncreaseActionTag)
        
        //pause the screen and show the controls to the player:
        pauseGame()
        
    }
    
    private func formDifficultyIncreaseAction() -> [SKAction] {
        
        var difficultyIncreaseAction: [SKAction] = []
        difficultyIncreaseAction.append(SKAction.wait(forDuration: TimeInterval(difficultyIncreaseInterval)))
        difficultyIncreaseAction.append(SKAction.run {
            
            if ((DifficultyScales.currentDifficulty + 1) < DifficultyScales.platformMovementTimes.count) {
                
                //not yet at max speed:
                DifficultyScales.currentDifficulty+=1
                self.platformMovementTime = DifficultyScales.platformMovementTimes[DifficultyScales.currentDifficulty]
                
                self.backgroundColor = SKColor(cgColor: DifficultyColors.getBackgroundColor())
                
                if (self.currentPlatformThatPlayerNeedsToDodge != nil) {
                    
                    self.currentPlatformThatPlayerNeedsToDodge?.updateColorOfPlatform()
                    
                }
                
            }
            
        })
        
        return difficultyIncreaseAction
        
    }
    
    public func resetDifficulty() {
        
        DifficultyScales.currentDifficulty = 0
        platformMovementTime = DifficultyScales.platformMovementTimes[0]
        
        self.backgroundColor = UIColor(cgColor: DifficultyColors.getBackgroundColor())
        
        if (currentPlatformThatPlayerNeedsToDodge != nil) {
            
            currentPlatformThatPlayerNeedsToDodge?.updateColorOfPlatform()
            
        }
        
        if self.action(forKey: difficultyIncreaseActionTag) != nil {
            
            //restart this action:
            self.removeAction(forKey: difficultyIncreaseActionTag)
            self.run(SKAction.repeatForever(SKAction.sequence(formDifficultyIncreaseAction())), withKey: difficultyIncreaseActionTag)
            
        }
        
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

            }
            else {
                
                if (!currentPlatformThatPlayerNeedsToDodge!.ghostModeActive) {
                    
                    currentPlatformThatPlayerNeedsToDodge!.toggleGhostMode(on: true)
                    
                }
                
            }
            
            
        }
        
    }
    
    private func pauseGame() {
            
        gameIsPaused = true
        
        
        mainCube?.pauseOrResumeCubeMovement(pause: true)
    
        if (currentPlatformThatPlayerNeedsToDodge != nil) {
            
            currentPlatformThatPlayerNeedsToDodge?.pauseOrUnpauseAllPlatformMovement(pause: true)
            
        }
        
        //pause difficulty increase action:
        if let difficultyIncreaseAction = self.action(forKey: difficultyIncreaseActionTag) {
            
            difficultyIncreaseAction.speed = 0
            
        }
        
        for (platformID, _) in platformsThatHavePassedPlayerAlready {
            
            platformsThatHavePassedPlayerAlready[platformID]?.pauseOrUnpauseAllPlatformMovement(pause: true)
            
        }
        
        if (needToShowGameControlsToPlayer) {
                        
            //the game was paused because the controls are being displayed:
            pauseScreenLabel = SKLabelNode(fontNamed: "Our-Arcade-Games")
            pauseScreenLabel?.fontSize = 30
            pauseScreenLabel?.color = UIColor(cgColor: textColor)
            pauseScreenLabel?.text = "HOW TO PLAY"
            pauseScreenLabel?.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 1.1)
            pauseScreenLabel?.zPosition = 20
            self.addChild(pauseScreenLabel!)
            
            //the swipe up arrow:
            let downscaleFactor: CGFloat = 1.35
            let verticalSpacing: CGFloat = 180
            let xOffset: CGFloat = 90
            swipeUpArrow = SKSpriteNode(imageNamed: "helperArrow")
            swipeUpArrow.scale(to: CGSize(width: swipeUpArrow.size.width / downscaleFactor, height: swipeUpArrow.size.height / downscaleFactor))
            swipeUpArrow.position = CGPoint(x: (self.frame.size.width / 2) - xOffset, y: (self.frame.size.height / 2) + (verticalSpacing / 2))
            swipeUpArrow.zPosition = 20
            
            swipeDownArrow = SKSpriteNode(imageNamed: "helperArrow")
            swipeDownArrow.position = CGPoint(x: (self.frame.size.width / 2) - xOffset, y: (self.frame.size.height / 2) - (verticalSpacing / 2))
            swipeDownArrow.scale(to: CGSize(width: swipeDownArrow.size.width / downscaleFactor, height: swipeDownArrow.size.height / downscaleFactor))
            swipeDownArrow.yScale *= -1
            swipeDownArrow.zPosition = 20
            
            self.addChild(swipeUpArrow)
            self.addChild(swipeDownArrow)
            
            swipeLabels = []
            let labelYOffset: CGFloat = 25
            let labelXOffset: CGFloat = 45
            let fontSizeOfHelperLabels: CGFloat = 14
            var currentYCordOfSwipeLabels = swipeUpArrow.position.y + labelYOffset
            var messages = ["Swipe up", "to slide", "vertical platform up"]
            for i in 0..<3 {
            
                let swipeUpLabel = SKLabelNode(fontNamed: "Our-Arcade-Games")
                swipeUpLabel.fontSize = fontSizeOfHelperLabels
                swipeUpLabel.text = messages[i]
                swipeUpLabel.position = CGPoint(x: (self.frame.size.width / 2) + labelXOffset, y: currentYCordOfSwipeLabels)
                swipeUpLabel.zPosition = 20
                
                currentYCordOfSwipeLabels -= labelYOffset
                self.addChild(swipeUpLabel)
                swipeLabels.append(swipeUpLabel)

            }
            
            messages[0] = "Swipe down"
            messages[2] = "vertical platform down"
            currentYCordOfSwipeLabels = swipeDownArrow.position.y + labelYOffset
            for i in 0..<3 {
                
                let swipeDownLabel = SKLabelNode(fontNamed: "Our-Arcade-Games")
                swipeDownLabel.fontSize = fontSizeOfHelperLabels
                swipeDownLabel.text = messages[i]
                swipeDownLabel.position = CGPoint(x: (self.frame.size.width / 2) + labelXOffset, y: currentYCordOfSwipeLabels)
                swipeDownLabel.zPosition = 20
                
                currentYCordOfSwipeLabels -= labelYOffset
                self.addChild(swipeDownLabel)
                swipeLabels.append(swipeDownLabel)
                
            }
            
            
            self.howToStartGameLabel = SKLabelNode(fontNamed: "Our-Arcade-Games")
            self.howToStartGameLabel.fontSize = 30
            self.howToStartGameLabel.text = "TAP TO BEGIN"
            self.howToStartGameLabel.position = CGPoint(x: self.frame.size.width / 2, y: 0 + self.frame.size.height / 13.5)
            self.howToStartGameLabel.zPosition = 20
            
            var blinkAction: [SKAction] = []
            blinkAction.append(SKAction.wait(forDuration: 0.85))
            blinkAction.append(SKAction.run {
                
                self.howToStartGameLabel.text = ""
                
            })
            blinkAction.append(SKAction.wait(forDuration: 0.85))
            blinkAction.append(SKAction.run {
                
                self.howToStartGameLabel.text = "TAP TO BEGIN"

            })

            howToStartGameLabel.run(SKAction.repeatForever(SKAction.sequence(blinkAction)))
            
            self.addChild(self.howToStartGameLabel)
            
            pauseScreenBG = SKSpriteNode(imageNamed: "platform")
            pauseScreenBG?.scale(to: CGSize(width: (pauseScreenBG?.size.width)! * 50, height: (pauseScreenBG?.size.height)! * 20))
            pauseScreenBG?.colorBlendFactor = 1
            pauseScreenBG?.color = UIColor(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 0.8))
            pauseScreenBG?.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
            pauseScreenBG?.zPosition = 19
            self.addChild(pauseScreenBG!)
            
        }
        else {
            
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
        
        doingAButtonFunctionAlready = false
        
        if (needToShowGameControlsToPlayer) {
            
            //game was resumed out of the game controls screen:
            for helpLabel in swipeLabels {
                
                helpLabel.removeFromParent()
                
            }
            
            swipeUpArrow.removeFromParent()
            swipeDownArrow.removeFromParent()
            howToStartGameLabel.removeFromParent()
            
            needToShowGameControlsToPlayer = false
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (doingAButtonFunctionAlready || gameIsEnding) {
            
            return
            
        }
        
        if (needToShowGameControlsToPlayer) {
            
            //was showing the game controls to the player:
            resumeGame()
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
        
        if ((currentPlatformThatPlayerNeedsToDodge == nil) || currentPlatformThatPlayerNeedsToDodge!.passedCubeAlready) {
                        
            currentPlatformThatPlayerNeedsToDodge = PlatformManager(scene: self, platformMovementTime: platformMovementTime, platformSlitSpacing: (mainCube!.getMainCubeSize().height * 2) + additionalSlitSpacing, xCordAtWhichCubeIsPassed: mainCube!.getMainCubePosition().x + (mainCube!.getMainCubeSize().width / 3.5), platformID: "Platform\(/*platformsSpawnedInSoFar!.count*/numberOfPlatformsOnScreenStill)", canAttemptToSpawnPowerUp: !ghostPowerUpActive)
            
            numberOfPlatformsOnScreenStill+=1
            
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
            
            if (currentPlatformThatPlayerNeedsToDodge != nil) {
                
                if (!currentPlatformThatPlayerNeedsToDodge!.passedCubeAlready) {
                    
                    currentPlatformThatPlayerNeedsToDodge?.ManagePlatformScrolling(yTranslation: yTranslation, scene: self)
                    
                }
                
            }

        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!gameIsEnding) {
            
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
            platformsThatHavePassedPlayerAlready.removeValue(forKey: IDOfPlatformToRemove)
            
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
                
        if (!gameIsEnding) {
            
            manageGhostPowerUpActivity()
            
            if (currentPlatformThatPlayerNeedsToDodge != nil) {
                
                if (!currentPlatformThatPlayerNeedsToDodge!.passedCubeAlready) {
                    
                    if (currentPlatformThatPlayerNeedsToDodge!.checkForWhenThisPlatformPassesMainCube()) {
                        
                        /*
     
                            place this into the platforms that player has dodged dictionary
                            so that if it collides with the cube on retract, the collision
                            is not counted
                         
                        */
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
                    
                    if ((platformsThatHavePassedPlayerAlready[(secondBody.node!.name)!] != nil) || currentPlatformThatPlayerNeedsToDodge!.ghostModeActive) {
                        
                        //the cube hit a platform that it already passed, or ghost power up is active
                        return
                        
                    }
                    
                    //the main cube hit a platform and should explode:
                    gameIsEnding = true
                    
                    if (currentPlatformThatPlayerNeedsToDodge != nil) {
                        
                        currentPlatformThatPlayerNeedsToDodge!.pauseOrUnpauseAllPlatformMovement(pause: true)
                        
                    }
                    
                    for (platformID, _) in platformsThatHavePassedPlayerAlready {
                        
                        platformsThatHavePassedPlayerAlready[platformID]?.pauseOrUnpauseAllPlatformMovement(pause: true)
                        
                    }
                    
                    mainCube?.doDeath()
                    
                }
                else if (secondBody.categoryBitMask == PhysicsCategories.powerUps) {
                    
                    if (!ghostPowerUpActive) {
                        
                        currentPlatformThatPlayerNeedsToDodge!.toggleGhostMode(on: true)
                        currentPlatformThatPlayerNeedsToDodge!.spawnedPowerUp!.doPowerUpFunctionality(gameManager: self)
                        
                    }
                    
                    
                }
            
            }
            
        }
        
    }
    
}
