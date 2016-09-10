//
//  Stack.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 7/3/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation

/**
 A first-in, last-out array (stack) where only the top element is accessible.
 
 Note: This could also be implemented as a linked list. According to my benchmarking,
 (in which I created an array and appended 100 elements, and compared it to creating
 a linked list node and appending 100 elements), a linked list implementation would
 be 30% faster. However, it would also cause the Stack not to behave like a struct
 (because you wouldn't technically be mutating properties, although if say, you're
 keeping track of the count, you might). In other languages, you'd define a Stack
 protocol and have ArrayStack and LinkedStack implementations, but you can't declare
 variables of protocol type when those protocols have associated types, so I've
 left it as an array-based implementation for now.
 */
public struct Stack<T>: CustomStringConvertible {
    
    // MARK: - Properties
    
    private var array:[T] = []
    
    ///Number of items on stack.
    public var count:Int { return self.array.count }
    
    ///The top element of the stack, or nil if there is none.
    public var topValue:T? {
        return self.array.last
    }
    
    // MARK: - Setup
    
    public init() {
        
    }
    
    // MARK: - Logic
    
    /**
    Pushes a value onto the top of the stack. Invokes *pushHandler* when finished.
    
    - parameter value: The value to push.
    */
    public mutating func push(value:T) {
        self.array.append(value)
    }
    
    /**
    Pops a value from the top of the stack, if possible. Invokes *popHandler* if successful.

    - returns: The popped value, or nil if the stack was empty.
    */
    public mutating func pop() -> T? {
      
        if self.array.count <= 0 {
            return nil
        }
        
        let lastValue = self.array.removeLast()
        return lastValue
    }
    
    
    // MARK: - CustomStringConvertible
    
    public var description:String {
        var string = "[\n"
        for iii in 0..<self.count {
            string += "\(self.array[self.count - iii - 1])\n"
        }
        return string + "]"
    }
}
