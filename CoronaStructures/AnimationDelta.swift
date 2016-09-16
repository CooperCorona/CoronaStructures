//
//  AnimationDelta.swift
//  Gravity
//
//  Created by Cooper Knaak on 5/1/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience

public protocol AnimationDeltaProtocol: Interpolatable {
    static func -(_: Self, _: Self) -> Self
}

public func *(lhs:CGFloat, rhs:Int) -> Int { return Int(lhs * CGFloat(rhs)) }
public func *(lhs:CGFloat, rhs:Float) -> Float { return Float(lhs) * rhs }
public func *(lhs:CGFloat, rhs:Double) -> Double { return Double(lhs) * rhs }
extension Int:          AnimationDeltaProtocol {}
extension Float:        AnimationDeltaProtocol {}
extension Double:       AnimationDeltaProtocol {}
extension CGFloat:      AnimationDeltaProtocol {}
extension CGPoint:      AnimationDeltaProtocol {}
extension SCVector3:    AnimationDeltaProtocol {}
extension SCVector4:    AnimationDeltaProtocol {}

open class AnimationDelta<T: AnimationDeltaProtocol>: CustomStringConvertible {
    
    open let initialValue:T
    open let deltaValue:T
    
    open var description:String { return "Initial = \(self.initialValue), Delta = \(self.deltaValue)" }
    
    public init(start:T, delta:T) {
        
        self.initialValue = start
        self.deltaValue = delta
        
    }//initialize
    
    public convenience init(start:T, end:T) {
        
        self.init(start: start, delta: end - start)
        
    }//initialize
    
    public convenience init(delta:T, end:T) {
        
        self.init(start: end - delta, delta: delta)
        
    }//initialize
    
    open func valueForTime(_ time:CGFloat) -> T {
        return self.initialValue + time * self.deltaValue
    }
    
    open subscript(time:CGFloat) -> T {
        return self.valueForTime(time)
    }
    
}
