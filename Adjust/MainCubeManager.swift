//
//  MainCubeManager.swift
//  Adjust
//
//  Created by cpsc on 5/7/21.
//

import SpriteKit

/*
 
 Contains all of the behavior the
 red cube needs, such as its
 up and down movement, its death behavior, etc.
 
 */
class MainCubeManager {
    
    //the lower this is, the faster the cube will move
    private var cubeSpeed: CGFloat = 2.25
    
    //the speed of the explosion animation
    let fps = 0.065
    
    public var isDead = false
    
    //used to pause or resume the cube movement action
    private let cubeActionTag = "cubeMovement"
    
    //for the explosio animation
    private var explosionAtlas: SKTextureAtlas
    private var explosionFrames: [SKTexture]
    
    private var mainCube: SKSpriteNode
    
    let colliderBoxDownScaleFactor: CGFloat = 1.5
    
    init(scene: SKScene) {
        
        explosionAtlas = SKTextureAtlas(named: "playerDeath.atlas")
        explosionFrames = []
        for i in 1...explosionAtlas.textureNames.count {
            
            explosionFrames.append(SKTexture(imageNamed: "collect\(i)"))
            
        }
        
        mainCube = SKSpriteNode(imageNamed: "mainPlayer")
        mainCube.scale(to: CGSize(width: mainCube.size.width * 0.94, height: mainCube.size.height * 0.94))
        mainCube.position = CGPoint(x: scene.frame.size.width / 2.5, y: scene.frame.size.height  / 2)
        
        mainCube.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: mainCube.size.width / colliderBoxDownScaleFactor, height: mainCube.size.height / colliderBoxDownScaleFactor))
        mainCube.physicsBody?.isDynamic = true
        mainCube.physicsBody?.categoryBitMask = PhysicsCategories.mainCube
        mainCube.zPosition = 1
        
        //main cube should call collision method on contact with platforms or powerups
        mainCube.physicsBody?.contactTestBitMask = PhysicsCategories.platforms | PhysicsCategories.powerUps
        
        mainCube.physicsBody?.collisionBitMask = PhysicsCategories.none
        
        mainCube.run(SKAction.repeatForever(SKAction.sequence(formUpAndDownAction(scene: scene, startingXCord: mainCube.position.x, cubeHeight: mainCube.size.height))), withKey: cubeActionTag)
        scene.addChild(mainCube)
        
    }
    
    public func doDeath() {
        
        let deathSoundsToPickFrom = ["explosionOne.mp3", "explosionTwo.wav"]
        let deathSoundToPlay = deathSoundsToPickFrom[Int.random(in: 0..<deathSoundsToPickFrom.count)]
        
        //stop the movement action:
        mainCube.removeAction(forKey: cubeActionTag)
        
        var deathAction: [SKAction] = []
        deathAction.append(SKAction.playSoundFileNamed(deathSoundToPlay, waitForCompletion: false))
        deathAction.append(SKAction.animate(with: explosionFrames, timePerFrame: fps, resize: true, restore: false))
        
        //this final action lets the game scene manager know the cube is officially dead
        deathAction.append(SKAction.run {
            self.mainCube.removeFromParent()
            self.isDead = true
        })
        
        mainCube.run(SKAction.sequence(deathAction))
        
    }
    
    public func getMainCubePosition() -> CGPoint {
        
        return mainCube.position
        
    }
    
    public func getMainCubeSize() -> CGSize {
        
        return mainCube.size
        
    }
    
    public func pauseOrResumeCubeMovement(pause: Bool) {
        
        if (pause) {
            
            //pause cube movement
            if let cubeAction = mainCube.action(forKey: cubeActionTag) {
                
                cubeAction.speed = 0
                
            }
            
        }
        else {
            
            //resume cube movement
            if let cubeAction = mainCube.action(forKey: cubeActionTag) {
                
                cubeAction.speed = 1
                
            }
            
        }
        
    }
    
    //this is the move up and down action the cube constantly does on the game scene
    private func formUpAndDownAction(scene: SKScene, startingXCord: CGFloat, cubeHeight: CGFloat) -> [SKAction] {
        
        var moveUpAndDownAction = [SKAction]()
        moveUpAndDownAction.append(SKAction.move(to: CGPoint(x: startingXCord , y: cubeHeight / 2), duration: TimeInterval(cubeSpeed)))
        moveUpAndDownAction.append(SKAction.move(to: CGPoint(x: startingXCord, y: scene.frame.size.height - (cubeHeight / 2)), duration: TimeInterval(cubeSpeed)))
        return moveUpAndDownAction
        
    }
    
}
