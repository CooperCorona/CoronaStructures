//
//  SCVector3Array.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/18/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

open class SCVector3Array: NSObject {
   
    open var values:[GLfloat] = []
    //3 values per 1 vector
    open var count:Int { return self.values.count / 3}
    
    open func rangeForIndex(_ index:Int) -> CountableRange<Int> {
        
        return (index * 3)..<(index * 3 + 3)
        
    }//get corresponding range for index
    
    open func addValues(_ vectorValues:[GLfloat]) {
        
        self.values += vectorValues
        
    }//add values
    
    open func addVector(_ vector:SCVector3) {
        
        self.values.append(GLfloat(vector.x))
        self.values.append(GLfloat(vector.y))
        self.values.append(GLfloat(vector.z))
        
    }//add vector
    
    open func insertVector(_ vector:SCVector3, atIndex index:Int) {
        
        if (index < 0 || index > self.count) {
            return
        }
        
        self.values.insert(GLfloat(vector.x), at: index * 3 + 0)
        self.values.insert(GLfloat(vector.y), at: index * 3 + 1)
        self.values.insert(GLfloat(vector.z), at: index * 3 + 2)
    }//insert vector at index
    
    open func removeVectorAtIndex(_ index:Int) {
        
        self.values.removeSubrange(self.rangeForIndex(index))
        
    }//remove vector at index
    
    open func removeVectorsInRange(_ range:Range<Int>) {
        
        if range.lowerBound < 0 || range.upperBound >= self.count {
            return
        }
        
        let realRange = (range.lowerBound * 3)..<(range.upperBound * 3)
        self.values.removeSubrange(realRange)
    }
    
    open func changeVector(_ vector:SCVector3, atIndex index:Int) {
        
        self.values[index * 3 + 0] = GLfloat(vector.x)
        self.values[index * 3 + 1] = GLfloat(vector.y)
        self.values[index * 3 + 2] = GLfloat(vector.z)
        
    }//change vector at index
    
    open func removeAll() {
        self.values.removeAll(keepingCapacity: true)
    }
    
    open func setVectors(_ array:SCVector3Array) {
        self.values = array.values
    }
    
    
    subscript(index:Int) -> SCVector3 {
        get {
            let x = CGFloat(self.values[index * 3 + 0])
            let y = CGFloat(self.values[index * 3 + 1])
            let z = CGFloat(self.values[index * 3 + 2])
            
            return SCVector3(xValue: x, yValue: y, zValue: z)
        }
        set {
            self.changeVector(newValue, atIndex: index)
        }
    }
    
}

public func +=(lhs:SCVector3Array, rhs:SCVector3) {
    
    lhs.addVector(rhs)
    
}//append a vector
