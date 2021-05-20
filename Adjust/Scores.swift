//
//  Scores.swift
//  Adjust
//
//  Created by cpsc on 5/7/21.
//
import Foundation

/*
 
 Contains all of the functionality
 needed for saving and getting access
 to scores
 
 */
struct Scores {
    
    static var recentScore = 0
    static var highScore = 0
    
    private static let highScoreKey = "highScore"
    private static let recentScoreKey = "recentScore"
    
    private static var defaultStorage = UserDefaults.standard
    
    public static func loadScoresIn() {
        
        if let highscore = self.defaultStorage.value(forKey: highScoreKey) as? Int {
            
            self.highScore = highscore
            
        }
        else {
            
            self.highScore = 0
            
        }
        
        if let recentScore = self.defaultStorage.value(forKey: recentScoreKey) as? Int {
            
            self.recentScore = recentScore
            
        }
        else {
            
            self.recentScore = 0
            
        }
        
    }
    
    static func saveScore() -> Bool{
        
        var didObtainNewHighScore = false
        if (self.recentScore > self.highScore) {
            
            //save this score as a the new highscore:
            highScore = self.recentScore
            self.defaultStorage.setValue(highScore, forKey: self.highScoreKey)
            didObtainNewHighScore = true
            
        }
        
        self.defaultStorage.setValue(self.recentScore, forKey: self.recentScoreKey)
        
        return didObtainNewHighScore
        
    }
    
}
