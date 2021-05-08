//
//  BaseMenuSceneManager.swift
//  Adjust
//
//  Created by cpsc on 5/7/21.
//

import SpriteKit

class BaseMenuSceneManager: SKScene {

    private var newGameButton: SKSpriteNode?
    
    var doingButtonFunction = false
    
    //TODO:
    private var currentHighScore: Int?
    private var lastScore: Int?
    
    var increment = true
    var currentColorVal: CGFloat = 0.45
    var canChangeColor = false
    var levelTimer = Timer()
    
    func initializeScene(title: String, newGameBtnName: String, fontSize: CGFloat = 60, newHighScore: Bool = false) {
        
        backgroundColor = SKColor(cgColor: CGColor(red: currentColorVal, green: currentColorVal, blue: currentColorVal, alpha: 1))
        levelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.changeBGColor), userInfo: nil, repeats: true)
        
        //Initialize the game over scene
        let textColor: CGColor = CGColor(red: 173 / 255, green: 5 / 255, blue: 5 / 255, alpha: 1)
        
        //the scene title
        let sceneTitle = SKLabelNode(fontNamed: "Our-Arcade-Games")
        sceneTitle.fontSize = fontSize //was 140
        sceneTitle.fontColor = UIColor(cgColor: textColor)
        sceneTitle.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - (self.frame.size.height / 4.5))
        sceneTitle.text = title
        
        //bobble up and down animation on game title:
        sceneTitle.run(SKAction.repeatForever(SKAction.sequence(createBobbleUpAction(startingCord: sceneTitle.position))))
        
        self.addChild(sceneTitle)
        
        //high score label:
        let highScoreLabel = SKLabelNode(fontNamed: "Our-Arcade-Games")
        highScoreLabel.fontSize = 25 //was 65

        highScoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: (self.frame.size.height / 2) + (self.frame.size.height / 8.85))
        if (newHighScore) {
            
            highScoreLabel.fontColor = UIColor.black
            highScoreLabel.text = "NEW HIGH SCORE: \(Scores.highScore)"
            highScoreLabel.run(SKAction.repeatForever(SKAction.sequence(createBobbleUpAction(startingCord: highScoreLabel.position))))
            
        }
        else {
            
            highScoreLabel.fontColor = UIColor(cgColor: textColor)
            highScoreLabel.fontColor = UIColor(cgColor: textColor)
            highScoreLabel.text = "HIGH SCORE: \(Scores.highScore)"

        }
        self.addChild(highScoreLabel)
                
        let UISpacing: CGFloat = 80 //was 150
        
        //score label:
        let lastScoreLabel = SKLabelNode(fontNamed: "Our-Arcade-Games")
        lastScoreLabel.fontSize = 25 //was 65
        lastScoreLabel.fontColor = UIColor(cgColor: textColor)
        lastScoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: highScoreLabel.position.y - UISpacing)
        lastScoreLabel.text = "RECENT SCORE: \(Scores.recentScore)"
        self.addChild(lastScoreLabel)
        
        //new game button:
        newGameButton = SKSpriteNode(imageNamed: newGameBtnName)
        newGameButton!.name = "newGameBtn"
        newGameButton!.scale(to: CGSize(width: newGameButton!.size.width * 0.95, height: newGameButton!.size.height * 0.95))
        newGameButton!.position = CGPoint(x: self.frame.size.width / 2, y: lastScoreLabel.position.y - (newGameButton!.size.height / 2) - UISpacing)
        newGameButton!.zPosition = 10
        self.addChild(newGameButton!)
        
    }
    
    @objc private func changeBGColor() {
        
        if (!self.increment) {
            
            self.currentColorVal -= 0.01
            if (self.currentColorVal <= 0.45) {
                
                self.increment = true
                
            }
        }
        else {
            
            self.currentColorVal += 0.01
            if (self.currentColorVal > 0.65) {
                
                self.increment = false
                
            }
            
        }
        
        self.backgroundColor = SKColor(cgColor: CGColor(red: self.currentColorVal, green: self.currentColorVal, blue: self.currentColorVal, alpha: 1))
        
    }
    
    private func createBobbleUpAction(startingCord: CGPoint) -> [SKAction] {
        
        var bobbleAction = [SKAction]()
        bobbleAction.append(SKAction.move(to: CGPoint(x: startingCord.x, y: startingCord.y + 5), duration: 0.25))
        bobbleAction.append(SKAction.move(to: CGPoint(x: startingCord.x, y: startingCord.y - 5), duration: 0.25))
        
        return bobbleAction
        
    }
    
    //for pressing the start game button:
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (doingButtonFunction) {
            
            return
            
        }
        
        let touch = touches.first
        
        if let touchLocation = touch?.location(in: self) {
            
            let nodesArray = self.nodes(at: touchLocation)
            
            if nodesArray.first?.name == "newGameBtn" {
                
                doingButtonFunction = true
                self.run(SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false))
                //transition to the game scene:
                nodesArray.first?.run(SKAction.sequence(SharedFunctions.createButtonClickEffect(startingScales: newGameButton!.size)), completion: {
                    
                    let transition = SKTransition.flipVertical(withDuration: 0.5)
                    if let gameScene = GameScene(fileNamed: "GameScene") {
                        
                        self.view?.presentScene(gameScene, transition: transition)

                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
}
