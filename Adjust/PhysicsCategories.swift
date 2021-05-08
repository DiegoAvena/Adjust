//
//  PhysicsCategories.swift
//  Adjust
//
//  Created by cpsc on 5/7/21.
//

import Foundation

//used for collision detection
struct PhysicsCategories {
    
    static let none: UInt32 = 0
    static let mainCube: UInt32 = 0b1 //1
    static let platforms: UInt32 = 0b10 //2
    static let powerUps: UInt32 = 0b11 //3
    
}
