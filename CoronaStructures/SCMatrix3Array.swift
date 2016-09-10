//
//  SCMatrix3Array.swift
//  MatTest
//
//  Created by Cooper Knaak on 1/20/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import GLKit

public class SCMatrix3Array: NSObject {
    
    public var values:[GLfloat] = []
    
    public init(matrices:[[GLfloat]]) {
        
        for cur in matrices {
            values += cur
        }
        
        super.init()
    }
    
    public func rangeForIndex(index:Int) -> Range<Int> {
        
        return (9 * index)..<(9 * index + 9)
        
    }//range of values for index
    
    public func addMatrix(matrix:[GLfloat]) {
        
        self.values += matrix
        
    }//add matrix
    
    public func removeMatrixAtIndex(index:Int) {
        
        let range = self.rangeForIndex(index)
        self.values.removeRange(range)
        
    }//remove matrix at index
    
    public func changeMatrix(matrix:[GLfloat], atIndex index:Int) {
        
        let range = self.rangeForIndex(index)
        self.values.replaceRange(range, with: matrix)
        
    }//change matrix at index
    
    subscript(index:Int) -> [GLfloat] {
        get {
            if index < 0 || index > self.values.count / 9 {
                return []
            }
            
            var array:[GLfloat] = []
            for iii in (index * 9)..<(index * 9 + 9) {
                array.append(self.values[iii])
            }
            
            return array
        }
        set {
            self.changeMatrix(newValue, atIndex: index)
        }
    }
    
}
