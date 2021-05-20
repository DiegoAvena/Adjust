//
//  DifficultyScales.swift
//  Adjust
//
//  Created by cpsc on 5/12/21.
//

import SpriteKit

struct DifficultyScales {
    
    //the different platform movement speeds per difficulty
    static let platformMovementTimes: [CGFloat] = [3, 2.5, 2, 1.5, 1.3]
    
    static var currentDifficulty = 0
    
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
