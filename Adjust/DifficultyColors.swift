//
//  DifficultyColors.swift
//  Adjust
//
//  Created by cpsc on 5/18/21.
//

import SpriteKit

/*
 
 Contains each color setting used
 to signal the different difficulties to
 the player as they progress through
 the game
 
 */
struct DifficultyColors {
    
    /*
     
     I chose to store this as a 3D array because I was unable to
     access the individual r, g, and b values if I used the CGColor data
     type, which was needed in order to get the functionality of the ghost
     powerup to work (where the alpha values change to 0.5)
     
     The organization of the 2 colors is as follows:
        For each pair of colors:
            color at index 0 is the BG color,
            color 1 is the platform color
     
     Also, this is what the colors look like:
     
     level 1 color: Orange BG, black platforms
     level 2 color: yellow BG, light grey platforms
     level 3 color: Blue BG, light grey platforms
     level 4 color: Purple BG, orange platforms
     level 5 color: white BG, black platforms
     
     */
    
    static private let difficultyColors: [[[CGFloat]]] = [
        
        [[255/255, 118/255, 38/255], [0, 0, 0]],
        [[255/255, 204/255, 38/255], [35/255, 135/255, 135/255]],
        [[60/255, 141/255, 207/255], [207/255, 207/255, 207/255]],
        [[123/255, 66/255,135/255], [222/255, 112/255, 22/255]],
        [[1, 1, 1], [0, 0, 0]]
        
    ]
    
    static public func getCurrentRValue(forBackground: Bool = false) -> CGFloat {
        
        var index = 1
        if (forBackground) {
            
            index -= 1
            
        }
        
        return difficultyColors[DifficultyScales.currentDifficulty][index][0]
        
    }
    
    static public func getCurrentGValue(forBackground: Bool = false) -> CGFloat {
        
        var index = 1
        if (forBackground) {
            
            index -= 1
            
        }
        
        return difficultyColors[DifficultyScales.currentDifficulty][index][1]
        
    }
    
    static public func getCurrentBValue(forBackground: Bool = false) -> CGFloat {
        
        var index = 1
        if (forBackground) {
            
            index -= 1
            
        }
        
        return difficultyColors[DifficultyScales.currentDifficulty][index][2]
        
    }
    
    static public func getBackgroundColor() -> CGColor{
        
        let rawColorValues = difficultyColors[DifficultyScales.currentDifficulty][0]
        let backgroundColor = CGColor(red: rawColorValues[0], green: rawColorValues[1], blue: rawColorValues[2], alpha: 1)
        return backgroundColor
        
    }
    
    static public func getPlatformColor() -> CGColor {
        
        
        let rawColorValues = difficultyColors[DifficultyScales.currentDifficulty][1]
        let platformColor = CGColor(red: rawColorValues[0], green: rawColorValues[1], blue: rawColorValues[2], alpha: 1)
        return platformColor
        
    }
    
}
