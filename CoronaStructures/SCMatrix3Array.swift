//
//  SCMatrix3Array.swift
//  MatTest
//
//  Created by Cooper Knaak on 1/20/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import GLKit

open class SCMatrix3Array: NSObject {
    
    open var values:[GLfloat] = []
    
    public init(matrices:[[GLfloat]]) {
        
        for cur in matrices {
            values += cur
        }
        
        super.init()
    }
    
    open func rangeForIndex(_ index:Int) -> CountableRange<Int> {
        
        return (9 * index)..<(9 * index + 9)
        
    }//range of values for index
    
    open func addMatrix(_ matrix:[GLfloat]) {
        
        self.values += matrix
        
    }//add matrix
    
    open func removeMatrixAtIndex(_ index:Int) {
        
        let range = self.rangeForIndex(index)
        self.values.removeSubrange(range)
        
    }//remove matrix at index
    
    open func changeMatrix(_ matrix:[GLfloat], atIndex index:Int) {
        
        let range = self.rangeForIndex(index)
        self.values.replaceSubrange(range, with: matrix)
        
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
