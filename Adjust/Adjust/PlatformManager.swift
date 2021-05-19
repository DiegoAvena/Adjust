//
//  PlatformManager.swift
//  Adjust
//
//  Created by cpsc on 5/3/21.
//

import SpriteKit

class PlatformManager {
    
    private var platformID: String
    
    private var currentPlatformGroup: [SKSpriteNode]!
    private var initialYPositionsOfCurrentPlatformGroup: [CGFloat]!
    private let rubberBandSpeed: CGFloat = 0.085
    
    private var platformMovementTime: CGFloat
    
    private let platformRubberBandActionName = "platformRubberBand"
    private let platformMovementTag = "platformMovement"
    
    private var xCordAtWhichCubeIsPassed: CGFloat
    
    public var passedCubeAlready: Bool = false
    public var offTheScreenAlready: Bool = false
    
    let colliderSizeDownScaleFactor: CGFloat = 1.115
    
    private var platformColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
    
    public var spawnedPowerUp: PowerUpBaseManager?
    public var ghostModeActive: Bool = false
    private let ghostAlphaValue: CGFloat = 0.15
    
    private func setUpPhysicsOnPlatform(colliderSize: CGSize) -> SKPhysicsBody {
        
        let boxCollider = SKPhysicsBody(rectangleOf: CGSize(width: colliderSize.width / colliderSizeDownScaleFactor, height: colliderSize.height / colliderSizeDownScaleFactor))
        boxCollider.categoryBitMask = PhysicsCategories.platforms
        boxCollider.contactTestBitMask = PhysicsCategories.mainCube
        boxCollider.collisionBitMask = PhysicsCategories.none
        boxCollider.isDynamic = true
        
        return boxCollider
        
    }
    
    /*
     
     Use this method to change the color of a platform that
     the player still needs to dodge whenever the difficulty
     changes
     
     */
    public func updateColorOfPlatform() {
        
        if (ghostModeActive) {
            
            platformColor = CGColor(red: DifficultyColors.getCurrentRValue(), green: DifficultyColors.getCurrentGValue(), blue: DifficultyColors.getCurrentBValue(), alpha: ghostAlphaValue)
            
        }
        else {
            
            //platformColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
            platformColor = CGColor(red: DifficultyColors.getCurrentRValue(), green: DifficultyColors.getCurrentGValue(), blue: DifficultyColors.getCurrentBValue(), alpha: 1)
            
        }
        
        for platform in currentPlatformGroup {
            
            platform.color = UIColor(cgColor: platformColor)
            
        }
        
    }
    
    public func toggleGhostMode(on: Bool) {
        
        if (on) {
            
            platformColor = CGColor(red: DifficultyColors.getCurrentRValue(), green: DifficultyColors.getCurrentGValue(), blue: DifficultyColors.getCurrentBValue(), alpha: ghostAlphaValue)
            
        }
        else {
            
            //platformColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
            platformColor = CGColor(red: DifficultyColors.getCurrentRValue(), green: DifficultyColors.getCurrentGValue(), blue: DifficultyColors.getCurrentBValue(), alpha: 1)
            
        }
        
        ghostModeActive = on
        
        for platform in currentPlatformGroup {
            
            platform.color = UIColor(cgColor: platformColor)
            
        }
        
    }
    
    init(scene: SKScene, platformMovementTime: CGFloat, platformSlitSpacing: CGFloat, xCordAtWhichCubeIsPassed: CGFloat, platformID: String, canAttemptToSpawnPowerUp: Bool) {
        
        self.platformID = platformID
        
        self.platformMovementTime = platformMovementTime
        self.xCordAtWhichCubeIsPassed = xCordAtWhichCubeIsPassed
        
        let topPlatform = SKSpriteNode(imageNamed: "platform")
        
        //this number needed to insure correct scaling of power up icon:
        let heightRescaleFactor = scene.frame.size.height / topPlatform.size.height
        
        topPlatform.scale(to: CGSize(width: topPlatform.size.width, height: scene.frame.size.height))
        topPlatform.position = CGPoint(x: scene.frame.size.width * 1.5, y: scene.frame.size.height + (platformSlitSpacing / 2))
        topPlatform.colorBlendFactor = 1
        topPlatform.color = UIColor(cgColor: DifficultyColors.getPlatformColor())
        topPlatform.name = platformID
        topPlatform.physicsBody = setUpPhysicsOnPlatform(colliderSize: topPlatform.size)
        
        let bottomPlatform = SKSpriteNode(imageNamed: "platform")
        bottomPlatform.scale(to: CGSize(width: topPlatform.size.width, height: scene.frame.size.height))
        bottomPlatform.position = CGPoint(x: scene.frame.size.width * 1.5, y: 0 - (platformSlitSpacing / 2))
        bottomPlatform.colorBlendFactor = 1
        bottomPlatform.color = UIColor(cgColor: DifficultyColors.getPlatformColor())
        bottomPlatform.name = platformID
        bottomPlatform.physicsBody = setUpPhysicsOnPlatform(colliderSize: bottomPlatform.size)
        
        if (canAttemptToSpawnPowerUp) {
            
            if (DifficultyScales.determineIfPowerUpCanSpawn()) {
                
                var parentNode: SKSpriteNode
                var upperBound: CGFloat
                var lowerBound: CGFloat
                
                if (Int.random(in: 0..<2) == 0) {
                    
                    //spawn on top platform
                    parentNode = topPlatform
                    upperBound = -(topPlatform.size.height / heightRescaleFactor) / 2
                    lowerBound = (-platformSlitSpacing / 2) / heightRescaleFactor
                    
                }
                else {
                    
                    //spawn on bottom platform
                    parentNode = bottomPlatform
                    upperBound = (platformSlitSpacing / 2) / heightRescaleFactor
                    lowerBound = (bottomPlatform.size.height / heightRescaleFactor) / 2
                    
                }
                
                var spawningInDifficultyResetPowerUp = false
                if (DifficultyScales.currentDifficulty == DifficultyScales.getMaxDifficulty()) {
                    
                    //can potentially spawn a reset difficulty power up:
                    if (Int.random(in: 0..<2) == 0) {
                        
                        //spawn in a reset difficulty power up
                        spawnedPowerUp = DifficultyResetPowerUpManager(parentNode: parentNode, upperBound: upperBound, lowerBound: lowerBound, heightRescaleFactor: heightRescaleFactor)
                        spawningInDifficultyResetPowerUp = true
                    
                    }
                    
                }
                
                if (!spawningInDifficultyResetPowerUp) {
                    
                    //spawn ghost power up in
                    spawnedPowerUp = GhostPowerUpManager(parentNode: parentNode, upperBound: upperBound, lowerBound: lowerBound, heightRescaleFactor: heightRescaleFactor)
                    
                }
                
            }
        
        }
        
        var platformMovementAction = [SKAction]()
        platformMovementAction.append(SKAction.moveTo(x: -topPlatform.size.width / 2, duration: TimeInterval(platformMovementTime)))
        platformMovementAction.append(SKAction.run {
            self.offTheScreenAlready = true
            topPlatform.removeFromParent()
        })
        
        topPlatform.run(SKAction.sequence(platformMovementAction), withKey: platformMovementTag)
        scene.addChild(topPlatform)
        
        platformMovementAction = [SKAction]()
        platformMovementAction.append(SKAction.moveTo(x: -bottomPlatform.size.width / 2, duration: TimeInterval(platformMovementTime)))
        platformMovementAction.append(SKAction.run {
            bottomPlatform.removeFromParent()
        })
        
        bottomPlatform.run(SKAction.sequence(platformMovementAction), withKey: platformMovementTag)
        scene.addChild(bottomPlatform)
        
        currentPlatformGroup = [topPlatform, bottomPlatform]
        initialYPositionsOfCurrentPlatformGroup = [topPlatform.position.y, bottomPlatform.position.y]
                
    }
    
    public func getPlatformID() -> String {
        
        return platformID
        
    }
    
    private func makeSurePlatformsDoNotGetScrolledTooFar(yTranslation: CGFloat, scene: SKScene) -> [CGFloat]{
        
        var finalYCords = [currentPlatformGroup[0].position.y + yTranslation,
                           currentPlatformGroup[1].position.y + yTranslation]
        
        //make sure that the top of the top platform will still be at or above the top edge of the scene:
        if (currentPlatformGroup[0].position.y + yTranslation + (currentPlatformGroup[0].size.height / 2) < scene.frame.size.height) {
            
            // the top platform will slide in too much, do not allow anymore sliding:
            finalYCords = [currentPlatformGroup[0].position.y,
                           currentPlatformGroup[1].position.y]
            
        }
        else if ((currentPlatformGroup[1].position.y + yTranslation) - (currentPlatformGroup[1].size.height / 2) > 0) {
            
            // the bottom of the bottom platform will slide in too much, do not allow anymore sliding
            finalYCords = [currentPlatformGroup[0].position.y,
                           currentPlatformGroup[1].position.y]
            
        }
        
        return finalYCords
        
    }
    
    public func ManagePlatformScrolling(yTranslation: CGFloat, scene: SKScene) {
        
        let finalYCords: [CGFloat] = self.makeSurePlatformsDoNotGetScrolledTooFar(yTranslation: yTranslation, scene: scene)
        currentPlatformGroup[0].position = CGPoint(x: currentPlatformGroup[0].position.x, y: finalYCords[0])
        currentPlatformGroup[1].position = CGPoint(x: currentPlatformGroup[1].position.x, y: finalYCords[1])
        
    }
    
    public func makePlatformsRubberbandBack() {
        
        currentPlatformGroup[0].run(SKAction.moveTo(y: initialYPositionsOfCurrentPlatformGroup[0], duration: TimeInterval(rubberBandSpeed)), withKey: platformRubberBandActionName)
                    
        currentPlatformGroup[1].run(SKAction.moveTo(y: initialYPositionsOfCurrentPlatformGroup[1], duration: TimeInterval(rubberBandSpeed)), withKey: platformRubberBandActionName)
        
    }
    
    public func checkForWhenThisPlatformPassesMainCube() -> Bool{
        
        if (currentPlatformGroup[0].position.x < xCordAtWhichCubeIsPassed) {
            
            passedCubeAlready = true
            makePlatformsRubberbandBack()
            
            currentPlatformGroup[0].colorBlendFactor = 1
            let collectionColor = CGColor(red: 51/255, green: 110/255, blue: 47/255, alpha: 1)
            currentPlatformGroup[0].color = UIColor(cgColor: collectionColor)
            
            currentPlatformGroup[1].colorBlendFactor = 1
            currentPlatformGroup[1].color = UIColor(cgColor: collectionColor)
            
            return true
            
        }
        
        return false
        
    }
    
    public func pauseOrUnpauseAllPlatformMovement(pause: Bool) {
        
        if (spawnedPowerUp != nil) {
            
            spawnedPowerUp!.pauseOrUnPausePowerUp(pause: pause)
            
        }
        
        for platform in currentPlatformGroup {
            
            if let platformAction = platform.action(forKey: platformMovementTag) {
                
                if (pause) {
                    
                    platformAction.speed = 0
                    
                }
                else {
                    
                    platformAction.speed = 1
                    
                }
                
            }
            
            if let platformRubberBandAction = platform.action(forKey: platformRubberBandActionName) {
                
                if (pause) {
                    
                    platformRubberBandAction.speed = 0
                    
                }
                else {
                    
                    platformRubberBandAction.speed = 1
                    
                }
                
            }
            
        }
        
    }
    
}
