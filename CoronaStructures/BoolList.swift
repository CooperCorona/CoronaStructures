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

public class BoolList: NSObject, NSCoding, ArrayLiteralConvertible {
    
    public typealias BoolType = UInt32
    public typealias Element = BoolType
    
    public let boolSize = sizeof(BoolType) * 8
    public let bitCount:Int
    public let arrayCount:Int
    
    public private(set) var values:[BoolType] = []
    
    public init(size:Int) {
        
        self.bitCount   = size
        self.arrayCount = max(Int(ceil(CGFloat(self.bitCount) / CGFloat(self.boolSize))), 1)
        
        self.values = Array<BoolType>(count: self.arrayCount, repeatedValue: 0)
        
    }//initialize
    
    public init(values:[BoolType]) {
        self.arrayCount = values.count
        self.bitCount   = self.arrayCount * self.boolSize
        
        self.values = values
    }
    
    public convenience init(string:String) {
        self.init(values: string.componentsSeparatedByString(", ").map() { BoolType($0.getIntegerValue()) })
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
        
        self.bitCount = aDecoder.decodeIntegerForKey("Bit Count")
        self.arrayCount = aDecoder.decodeIntegerForKey("Array Count")
        
        for iii in 1...self.arrayCount {
            let curValue = aDecoder.decodeInt64ForKey("Value \(iii)")
            self.values.append(UInt32(curValue))
        }
        
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeInteger(self.bitCount, forKey: "Bit Count")
        aCoder.encodeInteger(self.arrayCount, forKey: "Array Count")
        
        for iii in 0..<self.arrayCount {
            aCoder.encodeInt64(Int64(self.values[iii]), forKey: "Value \(iii + 1)")
        }
        
    }//encode with coder
    
    
    public func amountTrue() -> Int {
        
        var amount = 0
        for iii in 0..<self.bitCount {
            if (self[iii]) {
                amount += 1
            }
        }
        
        return amount
    }//get number of bits set to 'true'
    
    public func percentTrue() -> CGFloat {
        let amount = self.amountTrue()
        
        return CGFloat(amount) / CGFloat(self.bitCount)
    }//get percent of bits set to 'true'
    
    //Performs a Logical Or | operation
    //on each element in each array
    public func combineWithArray(array:[BoolType]) {
        
        var index = 0
        for (iii, value) in array.enumerate() {
            
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
    
    public func combineWithBoolList(list:BoolList) {
        
        self.combineWithArray(list.values)
        
    }//combine with bool list
    
    
    public func indicesForIndex(index:Int) -> (array:Int, bit:BoolType) {
        
        return (index / self.boolSize, BoolType(index % self.boolSize))
        
    }//get indices for index
    
    public func getString() -> String {
        var str = "\(self.values[0])"
        for (_, val) in self.values.enumerateSkipFirst() {
            str += ", \(val)"
        }
        return str
    }
    
    public subscript(index:Int) -> Bool {
        
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
    
    public override var description:String { return "\(self.values)" }
    
}

public func |(lhs:BoolList, rhs:BoolList) -> BoolList {
    let orList = BoolList(values: lhs.values)
    orList.combineWithBoolList(rhs)
    return orList
}

infix operator |= { associativity none precedence 90 }
public func |=(lhs:BoolList, rhs:BoolList) {
    lhs.combineWithBoolList(rhs)
}
