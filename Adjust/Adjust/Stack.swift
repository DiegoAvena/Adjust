//
//  Stack.swift
//  Adjust
//
//  Created by cpsc on 5/3/21.
//

import Foundation

struct Stack<DataType> {
    
    private var collection = [DataType]()
    
    func peek() -> DataType? {
        
        return collection.last
        
    }
    
    mutating func push(newElement: DataType) {
        
        self.collection.append(newElement)
        
    }
    
    mutating func pop() -> DataType? {
        
        return collection.popLast()
        
    }
    
    
    
    
}
