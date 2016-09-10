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

public class SCVector3Array: NSObject {
   
    public var values:[GLfloat] = []
    //3 values per 1 vector
    public var count:Int { return self.values.count / 3}
    
    public func rangeForIndex(index:Int) -> Range<Int> {
        
        return (index * 3)..<(index * 3 + 3)
        
    }//get corresponding range for index
    
    public func addValues(vectorValues:[GLfloat]) {
        
        self.values += vectorValues
        
    }//add values
    
    public func addVector(vector:SCVector3) {
        
        self.values.append(GLfloat(vector.x))
        self.values.append(GLfloat(vector.y))
        self.values.append(GLfloat(vector.z))
        
    }//add vector
    
    public func insertVector(vector:SCVector3, atIndex index:Int) {
        
        if (index < 0 || index > self.count) {
            return
        }
        
        self.values.insert(GLfloat(vector.x), atIndex: index * 3 + 0)
        self.values.insert(GLfloat(vector.y), atIndex: index * 3 + 1)
        self.values.insert(GLfloat(vector.z), atIndex: index * 3 + 2)
    }//insert vector at index
    
    public func removeVectorAtIndex(index:Int) {
        
        self.values.removeRange(self.rangeForIndex(index))
        
    }//remove vector at index
    
    public func removeVectorsInRange(range:Range<Int>) {
        
        if range.startIndex < 0 || range.endIndex >= self.count {
            return
        }
        
        let realRange = (range.startIndex * 3)..<(range.endIndex * 3)
        self.values.removeRange(realRange)
    }
    
    public func changeVector(vector:SCVector3, atIndex index:Int) {
        
        self.values[index * 3 + 0] = GLfloat(vector.x)
        self.values[index * 3 + 1] = GLfloat(vector.y)
        self.values[index * 3 + 2] = GLfloat(vector.z)
        
    }//change vector at index
    
    public func removeAll() {
        self.values.removeAll(keepCapacity: true)
    }
    
    public func setVectors(array:SCVector3Array) {
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
