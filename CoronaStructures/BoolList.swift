//
//  BoolList.swift
//  Gravity
//
//  Created by Cooper Knaak on 3/27/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

open class BoolList: NSObject, NSCoding, ExpressibleByArrayLiteral {
    
    public typealias BoolType = UInt32
    public typealias Element = BoolType
    
    open let boolSize = MemoryLayout<BoolType>.size * 8
    open let bitCount:Int
    open let arrayCount:Int
    
    open fileprivate(set) var values:[BoolType] = []
    
    public init(size:Int) {
        
        self.bitCount   = size
        self.arrayCount = max(Int(ceil(CGFloat(self.bitCount) / CGFloat(self.boolSize))), 1)
        
        self.values = Array<BoolType>(repeating: 0, count: self.arrayCount)
        
    }//initialize
    
    public init(values:[BoolType]) {
        self.arrayCount = values.count
        self.bitCount   = self.arrayCount * self.boolSize
        
        self.values = values
    }
    
    public convenience init(string:String) {
        self.init(values: string.components(separatedBy: ", ").map() { BoolType($0.getIntegerValue()) })
    }
    
    // MARK: - ArrayLiteralConvertible
    
    public required init(arrayLiteral elements:Element...) {
        
        self.arrayCount = max(elements.count, 1)
        self.bitCount = self.arrayCount * self.boolSize
        
        self.values = elements
        
        if (self.values.count == 0) {
            self.values = [0]
        }
    }//initialize
    
    // MARK: - NSCoder
    
    public required init?(coder aDecoder:NSCoder) {
        
        self.bitCount = aDecoder.decodeInteger(forKey: "Bit Count")
        self.arrayCount = aDecoder.decodeInteger(forKey: "Array Count")
        
        for iii in 1...self.arrayCount {
            let curValue = aDecoder.decodeInt64(forKey: "Value \(iii)")
            self.values.append(UInt32(curValue))
        }
        
        super.init()
    }
    
    open func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.bitCount, forKey: "Bit Count")
        aCoder.encode(self.arrayCount, forKey: "Array Count")
        
        for iii in 0..<self.arrayCount {
            aCoder.encode(Int64(self.values[iii]), forKey: "Value \(iii + 1)")
        }
        
    }//encode with coder
    
    
    open func amountTrue() -> Int {
        
        var amount = 0
        for iii in 0..<self.bitCount {
            if (self[iii]) {
                amount += 1
            }
        }
        
        return amount
    }//get number of bits set to 'true'
    
    open func percentTrue() -> CGFloat {
        let amount = self.amountTrue()
        
        return CGFloat(amount) / CGFloat(self.bitCount)
    }//get percent of bits set to 'true'
    
    //Performs a Logical Or | operation
    //on each element in each array
    open func combineWithArray(_ array:[BoolType]) {
        
        var index = 0
        for (iii, value) in array.enumerated() {
            
            for jjj in 0..<self.boolSize {
                
                index = iii * self.boolSize + jjj
                
                if (index >= self.bitCount) {
                    break
                }
                
                if (Int(value) & (1 << jjj) != 0) {
                    self[index] = true
                }
                
            }//loop through bits
            
            if (index >= self.bitCount) {
                break
            }
            
        }//loop through array values
        
    }//combine with array
    
    open func combineWithBoolList(_ list:BoolList) {
        
        self.combineWithArray(list.values)
        
    }//combine with bool list
    
    
    open func indicesForIndex(_ index:Int) -> (array:Int, bit:BoolType) {
        
        return (index / self.boolSize, BoolType(index % self.boolSize))
        
    }//get indices for index
    
    open func getString() -> String {
        var str = "\(self.values[0])"
        for (_, val) in self.values.enumerateSkipFirst() {
            str += ", \(val)"
        }
        return str
    }
    
    open subscript(index:Int) -> Bool {
        
        get {
            if (index < 0 || index >= self.bitCount) {
                return false
            } else {
                let indices = self.indicesForIndex(index)
                return (self.values[indices.array] & (1 << indices.bit)) != 0
            }
        }
        
        set {
            if (index >= 0 && index < self.bitCount) {
                let indices = self.indicesForIndex(index)
                if (newValue) {
                    self.values[indices.array] |= BoolType(1 << indices.bit)
                } else {
                    self.values[indices.array] &= ~BoolType(1 << indices.bit)
                }
            }
        }
        
    }//subscript
    
    //MARK: - CustomStringConvertible
    
    open override var description:String { return "\(self.values)" }
    
}

public func |(lhs:BoolList, rhs:BoolList) -> BoolList {
    let orList = BoolList(values: lhs.values)
    orList.combineWithBoolList(rhs)
    return orList
}

infix operator |=: AssignmentPrecedence
public func |=(lhs:BoolList, rhs:BoolList) {
    lhs.combineWithBoolList(rhs)
}
