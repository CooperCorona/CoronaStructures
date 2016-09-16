//
//  IntPoint+Iterator.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 8/14/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Foundation
/*
extension IntPoint: Comparable {
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func <(lhs: IntPoint, rhs: IntPoint) -> Bool {
        <#code#>
    }

    
    public typealias Distance = Int
    
    public func distanceTo(_ end: IntPoint) -> Distance {
        return (end.y - self.y + 1) * (end.x - self.x + 1) - 1
    }
    
    public func successor() -> IntPoint {
        return IntPoint(x: self.x + 1, y: self.y)
    }
}
*/
public struct IntPointGenerator: Sequence, IteratorProtocol {
    
    fileprivate let start:IntPoint
    fileprivate let end:IntPoint
    fileprivate var current:IntPoint
    fileprivate var nextPoint:IntPoint?
    
    public init(start:IntPoint, end:IntPoint) {
        self.start      = start
        self.end        = end
        self.current    = start
        self.nextPoint  = self.current
    }
    
    public mutating func next() -> IntPoint? {
        let value = self.nextPoint
        if self.current == self.end {
            self.nextPoint = nil
        } else {
            self.current.x += 1
            if self.current.x > self.end.x {
                self.current.x = self.start.x
                self.current.y += 1
            }
            self.nextPoint = self.current
        }
        return value
    }
    
    public func makeIterator() -> IntPointGenerator {
        return self
    }
}

///Note that IntPointIterator is inclusive.
public struct IntPointIterator: Sequence {
    
    public let start:IntPoint
    public let end:IntPoint
    
    public init(start:IntPoint, end:IntPoint) {
        self.start = start
        self.end = end
    }
    
    ///Start is initialized to (0, 0).
    public init(end:IntPoint) {
        self.init(start: IntPoint(x: 0, y: 0), end: end)
    }
    
    public func makeIterator() -> IntPointGenerator {
        return IntPointGenerator(start: self.start, end: self.end)
    }
    
}

extension IntPoint: Sequence {
    
    public func iteratorFrom(_ start:IntPoint) -> IntPointIterator {
        return IntPointIterator(start: start, end: self)
    }
    
    public func iteratorTo(_ end:IntPoint) -> IntPointIterator {
        return IntPointIterator(start: self, end: end)
    }
    
    public func makeIterator() -> IntPointGenerator {
        return IntPointIterator(end: self).makeIterator()
    }
    
}
