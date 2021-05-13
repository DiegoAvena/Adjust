//
//  DifficultyScales.swift
//  Adjust
//
//  Created by cpsc on 5/12/21.
//

import SpriteKit

struct DifficultyScales {
    
    static let platformMovementTimes: [CGFloat] = [3, 2.5, 2, 1.5, 1.3]
    static var currentDifficulty = 0
    
    //color 0 is the BG color, color 1 is the platform color
    static let difficultyColors = [
    
        [CGColor(red: 255/255, green: 118/255, blue: 38/255, alpha: 1), CGColor(red: 0, green: 0, blue: 0, alpha: 1)],
        [CGColor(red: 255/255, green: 204/255, blue: 38/255, alpha: 1), CGColor(red: 135, green: 135, blue: 135, alpha: 1)],
        [CGColor(red: 60/255, green: 141/255, blue: 207/255, alpha: 1), CGColor(red: 207, green: 207, blue: 207, alpha: 1)],
        [CGColor(red: 123/255, green: 66/255, blue: 135/255, alpha: 1), CGColor(red: 222, green: 112, blue: 22, alpha: 1)],
        [CGColor(red: 1, green: 1, blue: 1, alpha: 1), CGColor(red: 0, green: 0, blue: 0, alpha: 1)]
    
    ]
    
    /*
     
     Chances of a power up spawning:
     
     difficulty 0: 0%
     difficulty 1: 0.1%
     difficulty 2: 0.2%
     difficulty 3: 0.3%
     difficulty 4: 0.4%
     
     */
    static let powerUpRespawnChances = [
        
        [false, false, false, false, false, false, false, false, false, false],
        [true, false, false, false, false, false, false, false, false, false],
        [true, true, false, false, false, false, false, false, false, false],
        [true, true, true, false, false, false, false, false, false, false],
        [true, true, true, true, false, false, false, false, false, false],
    
    ]
    
    public static func getMaxDifficulty() -> Int {
        
        return platformMovementTimes.count - 1
        
    }
    
    public static func determineIfPowerUpCanSpawn() -> Bool {
        
        return powerUpRespawnChances[currentDifficulty][Int.random(in: 0..<powerUpRespawnChances[0].count)]
        
    }
    
}
