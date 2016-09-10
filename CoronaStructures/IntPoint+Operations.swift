//
//  IntPoint+Operations.swift
//  CoronaPathfinding
//
//  Created by Cooper Knaak on 12/5/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation

// IntPoint -- IntPoint

public func ==(lhs:IntPoint, rhs:IntPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

public func +(lhs:IntPoint, rhs:IntPoint) -> IntPoint {
    return IntPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func +=(inout lhs:IntPoint, rhs:IntPoint) {
    return lhs = lhs + rhs
}

public func -(lhs:IntPoint, rhs:IntPoint) -> IntPoint {
    return IntPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func -=(inout lhs:IntPoint, rhs:IntPoint) {
    return lhs = lhs - rhs
}

public func *(lhs:IntPoint, rhs:IntPoint) -> IntPoint {
    return IntPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

public func *=(inout lhs:IntPoint, rhs:IntPoint) {
    return lhs = lhs * rhs
}

public func /(lhs:IntPoint, rhs:IntPoint) -> IntPoint {
    return IntPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
}

public func /=(inout lhs:IntPoint, rhs:IntPoint) {
    return lhs = lhs / rhs
}

// IntPoint -- Int

public func +(lhs:IntPoint, rhs:Int) -> IntPoint {
    return IntPoint(x: lhs.x + rhs, y: lhs.y + rhs)
}

public func +(lhs:Int, rhs:IntPoint) -> IntPoint {
    return IntPoint(x: lhs + rhs.x, y: lhs + rhs.y)
}

public func +=(inout lhs:IntPoint, rhs:Int) {
    lhs = lhs + rhs
}

public func -(lhs:IntPoint, rhs:Int) -> IntPoint {
    return IntPoint(x: lhs.x - rhs, y: lhs.y - rhs)
}

public func -(lhs:Int, rhs:IntPoint) -> IntPoint {
    return IntPoint(x: lhs - rhs.x, y: lhs - rhs.y)
}

public func -=(inout lhs:IntPoint, rhs:Int) {
    lhs = lhs - rhs
}

public func *(lhs:IntPoint, rhs:Int) -> IntPoint {
    return IntPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

public func *(lhs:Int, rhs:IntPoint) -> IntPoint {
    return IntPoint(x: lhs * rhs.x, y: lhs * rhs.y)
}

public func *=(inout lhs:IntPoint, rhs:Int) {
    lhs = lhs * rhs
}

public func /(lhs:IntPoint, rhs:Int) -> IntPoint {
    return IntPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}

public func /(lhs:Int, rhs:IntPoint) -> IntPoint {
    return IntPoint(x: lhs / rhs.x, y: lhs / rhs.y)
}

public func /=(inout lhs:IntPoint, rhs:Int) {
    lhs = lhs / rhs
}
