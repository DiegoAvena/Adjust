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
    
    private var spawnedPowerUp: PowerUpBaseManager?
    
    private func setUpPhysicsOnPlatform(colliderSize: CGSize) -> SKPhysicsBody {
        
        let boxCollider = SKPhysicsBody(rectangleOf: CGSize(width: colliderSize.width / colliderSizeDownScaleFactor, height: colliderSize.height / colliderSizeDownScaleFactor))
        boxCollider.categoryBitMask = PhysicsCategories.platforms
        boxCollider.contactTestBitMask = PhysicsCategories.mainCube
        boxCollider.collisionBitMask = PhysicsCategories.none
        boxCollider.isDynamic = true
        
        return boxCollider
        
    }
    
    init(scene: SKScene, platformMovementTime: CGFloat, platformSlitSpacing: CGFloat, xCordAtWhichCubeIsPassed: CGFloat, platformID: String) {
        
        self.platformID = platformID
        
        self.platformMovementTime = platformMovementTime
        self.xCordAtWhichCubeIsPassed = xCordAtWhichCubeIsPassed
        
        let topPlatform = SKSpriteNode(imageNamed: "platform")
        
        //this number needed to insure correct scaling of power up icon:
        let heightRescaleFactor = scene.frame.size.height / topPlatform.size.height
        
        topPlatform.scale(to: CGSize(width: topPlatform.size.width, height: scene.frame.size.height))
        topPlatform.position = CGPoint(x: scene.frame.size.width * 1.5, y: scene.frame.size.height + (platformSlitSpacing / 2))
        topPlatform.colorBlendFactor = 1
        topPlatform.color = UIColor(cgColor: CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        topPlatform.name = platformID
        topPlatform.physicsBody = setUpPhysicsOnPlatform(colliderSize: topPlatform.size)
        
        // spawn in a power up:
        //let ghostPowerUp = PowerUpBaseManager(parentNode: topPlatform, upperBound: (-(topPlatform.size.height / heightRescaleFactor) / 2), lowerBound: (-platformSlitSpacing / 2) / heightRescaleFactor , powerUpName: "ghostPowerUp", heightRescaleFactor: heightRescaleFactor)
        
        let bottomPlatform = SKSpriteNode(imageNamed: "platform")
        bottomPlatform.scale(to: CGSize(width: topPlatform.size.width, height: scene.frame.size.height))
        bottomPlatform.position = CGPoint(x: scene.frame.size.width * 1.5, y: 0 - (platformSlitSpacing / 2))
        bottomPlatform.colorBlendFactor = 1
        bottomPlatform.color = UIColor(cgColor: CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        bottomPlatform.name = platformID
        bottomPlatform.physicsBody = setUpPhysicsOnPlatform(colliderSize: bottomPlatform.size)
        
        //let ghostPowerUpTwo = PowerUpBaseManager(parentNode: bottomPlatform, upperBound: ((platformSlitSpacing / 2) / heightRescaleFactor), lowerBound:  ((bottomPlatform.size.height / heightRescaleFactor) / 2), powerUpName: "resetPowerUp", heightRescaleFactor: heightRescaleFactor)
        spawnedPowerUp = PowerUpBaseManager(parentNode: bottomPlatform, upperBound: ((platformSlitSpacing / 2) / heightRescaleFactor), lowerBound:  ((bottomPlatform.size.height / heightRescaleFactor) / 2), powerUpName: "resetPowerUp", heightRescaleFactor: heightRescaleFactor)
        
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
            currentPlatformGroup[0].color = UIColor(cgColor: CGColor(red: 0, green: 1, blue: 0.65, alpha: 1))
            
            currentPlatformGroup[1].colorBlendFactor = 1
            currentPlatformGroup[1].color = UIColor(cgColor: CGColor(red: 0, green: 1, blue: 0.65, alpha: 1))
            
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
