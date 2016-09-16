//
//  SCMatrix4Array.swift
//  MatTest
//
//  Created by Cooper Knaak on 1/19/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

open class SCMatrix4Array: NSObject {

    open var values:[GLfloat] = []
    //16 values per 1 matrix
    open var count:Int { return self.values.count / 16}
    
    public init(matrices:[SCMatrix4]) {
        
        for cur in matrices {
            values += cur.values
        }
        
        super.init()
    }
    
    open func rangeForIndex(_ index:Int) -> CountableRange<Int> {
        
        return (16 * index)..<(16 * index + 16)
        
    }//range of values for index
    
    open func addMatrix(_ matrix:SCMatrix4) {
        
        self.values += matrix.values
        
    }//add matrix
    
    open func insertMatrix(_ matrix:SCMatrix4, atIndex index:Int) {
        
        if (index < 0 || index > self.count) {
            return
        }
        
        var matrixIndex = 0
        let range = self.rangeForIndex(index)
        for iii in range {
            self.values.insert(matrix.values[matrixIndex], at: iii)
            matrixIndex += 1
        }
    }//insert matrix at index
    
    open func removeMatrixAtIndex(_ index:Int) {
        
        let range = self.rangeForIndex(index)
        self.values.removeSubrange(range)
        
    }//remove matrix at index
    
    open func removeMatricesInRange(_ range:Range<Int>) {
        
        if range.lowerBound < 0 || range.upperBound >= self.count {
            return
        }
        
        let realRange = (range.lowerBound * 16)..<(range.upperBound * 16)
        self.values.removeSubrange(realRange)
    }
    
    open func changeMatrix(_ matrix:SCMatrix4, atIndex index:Int) {
        
        let range = self.rangeForIndex(index)
        self.values.replaceSubrange(range, with: matrix.values)
    }//change matrix at index
    
    open func changeMatrix_Fast2D(_ matrix:SCMatrix4, atIndex index:Int) {
        
        let startIndex = index * 16
        self.values[startIndex     ] = matrix.values[0 ]
        self.values[startIndex + 1 ] = matrix.values[1 ]
        self.values[startIndex + 4 ] = matrix.values[4 ]
        self.values[startIndex + 5 ] = matrix.values[5 ]
        self.values[startIndex + 12] = matrix.values[12]
        self.values[startIndex + 13] = matrix.values[13]
        self.values[startIndex + 14] = matrix.values[14]
    }//change matrix at index (using only 2d components)
    
    open func removeAll() {
        self.values.removeAll(keepingCapacity: true)
    }//remove all
    
    open func setMatrices(_ array:SCMatrix4Array) {
        self.values = array.values
    }
    
    open subscript(index:Int) -> SCMatrix4 {
        get {
            var array:[GLfloat] = []
            for iii in (index * 16..<index * 16 + 16) {
                array.append(self.values[iii])
            }
            return SCMatrix4(array: array)
        }
        set {
            self.changeMatrix(newValue, atIndex: index)
        }
    }
    
    
    open override var description:String {
        var str = ""
        for iii in 0..<self.count {
            str += "[\(iii)]: \(self[iii])\n"
        }
        return str
    }
}

