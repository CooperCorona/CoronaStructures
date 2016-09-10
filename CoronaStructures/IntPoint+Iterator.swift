//
//  IntPoint+Iterator.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 8/14/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Foundation

extension IntPoint: ForwardIndexType {
    
    public typealias Distance = Int
    
    public func distanceTo(end: IntPoint) -> Distance {
        return (end.y - self.y + 1) * (end.x - self.x + 1) - 1
    }
    
    public func successor() -> IntPoint {
        return IntPoint(x: self.x + 1, y: self.y)
    }
}

public struct IntPointGenerator: SequenceType, GeneratorType {
    
    private let start:IntPoint
    private let end:IntPoint
    private var current:IntPoint
    private var nextPoint:IntPoint?
    
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
    
    public func generate() -> IntPointGenerator {
        return self
    }
}

///Note that IntPointIterator is inclusive.
public struct IntPointIterator: SequenceType {
    
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
    
    public func generate() -> IntPointGenerator {
        return IntPointGenerator(start: self.start, end: self.end)
    }
    
}

extension IntPoint: SequenceType {
    
    public func iteratorFrom(start:IntPoint) -> IntPointIterator {
        return IntPointIterator(start: start, end: self)
    }
    
    public func iteratorTo(end:IntPoint) -> IntPointIterator {
        return IntPointIterator(start: self, end: end)
    }
    
    public func generate() -> IntPointGenerator {
        return IntPointIterator(end: self).generate()
    }
    
}