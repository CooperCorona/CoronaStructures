//
//  LinearInterpolation.swift
//  Gravity
//
//  Created by Cooper Knaak on 5/24/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience

// MARK: - Interpolatable Protocol

public protocol Interpolatable {
    static func *(_: CGFloat, _: Self) -> Self
    static func +(_: Self, _: Self) -> Self
    static func -(_: Self, _: Self) -> Self
}

// MARK: - Interpolatable Conformance

// MARK: - Linear Interpolation (1D)

/**
Interpolates between left and right.
```
    0---1
```
- returns: Linear Interpolation of left and right.
*/
public func linearlyInterpolate<T: Interpolatable>(_ midX:CGFloat, left:T, right:T) -> T {
    return (1.0 - midX) * left + midX * right
}

// MARK: - Bilinear Interpolation (2D)

public func bilinearlyInterpolate<T: Interpolatable>(_ mid:CGPoint, leftBelow:T, rightBelow:T, leftAbove:T, rightAbove:T) -> T {
    
    let below = linearlyInterpolate(mid.x, left: leftBelow, right: rightBelow)
    let above = linearlyInterpolate(mid.x, left: leftAbove, right: rightAbove)
    
    return linearlyInterpolate(mid.y, left: below, right: above)
}

/**
Values must be in this order:

0) Bottom Left
1) Bottom Right
2) Top Left
3) Top Right

**See Diagram:**
```
    2--3
    |  |
    0--1
```
- returns: Bilinear Interpolation of values, nil if there are less then 4 values.
*/
public func bilinearlyInterpolate<T: Interpolatable>(_ mid:CGPoint, values:[T]) -> T? {
    if (values.count < 4) {
        return nil
    }
    
    return bilinearlyInterpolate(mid, leftBelow: values[0], rightBelow: values[1], leftAbove: values[2], rightAbove: values[3])
}

// MARK: - Trilinear Interpolation (3D)
public func trilinearlyInterpolate<T: Interpolatable>(_ mid:SCVector3, leftBelowBehind:T, rightBelowBehind:T, leftAboveBehind:T, rightAboveBehind:T, leftBelowFront:T, rightBelowFront:T, leftAboveFront:T, rightAboveFront:T) -> T {
    
    let bilinearMid = CGPoint(x: mid.x, y: mid.y)
    let behind = bilinearlyInterpolate(bilinearMid, leftBelow: leftBelowBehind, rightBelow: rightBelowBehind, leftAbove: leftAboveBehind, rightAbove: rightAboveBehind)
    let front = bilinearlyInterpolate(bilinearMid, leftBelow: leftBelowFront, rightBelow: rightBelowFront, leftAbove: leftAboveFront, rightAbove: rightAboveFront)
    
    return linearlyInterpolate(mid.z, left: behind, right: front)
}


/**
Returns 'nil' if the number of 'values' array doesn't have enough (8) elements.
Values must be in this order:

0) Bottom Left Behind
1) Bottom Right Behind
2) Top Left Behind
3) Top Right Behind
4) Bottom Left Front
5) Bottom Right Front
6) Top Left Front
7) Top Right Front

**See Diagram:**
```
         6-----7
        /|    /|
       / |   / |
      /  4--/--5
     2-----3  /
     | /   | /
     |/    |/
     0-----1
```
- returns: Trilinear Interpolation of values, nil if there are less than 8 values.
*/
public func trilinearlyInterpolate<T: Interpolatable>(_ mid:SCVector3, values:[T]) -> T? {
    if (values.count < 8) {
        return nil
    }
    
    return trilinearlyInterpolate(mid, leftBelowBehind: values[0], rightBelowBehind: values[1], leftAboveBehind: values[2], rightAboveBehind: values[3], leftBelowFront: values[4], rightBelowFront: values[5], leftAboveFront: values[6], rightAboveFront: values[7])
}

private struct TriangleLineSegment {
    var point1:CGPoint
    var point2:CGPoint
    var length:CGFloat { return self.point1.distanceFrom(self.point2) }
    
    func distance(from point:CGPoint) -> CGFloat {
        if self.point1.x ~= self.point2.x {
            return abs(point.x - self.point1.x)
        }
        let a = self.point2.y - self.point1.y
        let b = self.point2.x - self.point1.x
        let c = self.point2.x * self.point1.y - self.point1.x * self.point2.y
        return abs(a * point.x - b * point.y + c) / sqrt(a * a + b * b)
    }
}

public func triangularlyInterpolate<T: Interpolatable>(mid:CGPoint, vertex1:CGPoint, value1:T, vertex2:CGPoint, value2:T, vertex3:CGPoint, value3:T) -> T {
    let t1 = TriangleLineSegment(point1: vertex1, point2: vertex2)
    let t2 = TriangleLineSegment(point1: vertex2, point2: vertex3)
    let t3 = TriangleLineSegment(point1: vertex3, point2: vertex1)
    let area1 = t2.length * t2.distance(from: mid) / 2.0
    let area2 = t3.length * t3.distance(from: mid) / 2.0
    let area3 = t1.length * t1.distance(from: mid) / 2.0
    let area = area1 + area2 + area3
    return (area1 / area) * value1 + (area2 / area) * value2 + (area3 / area) * value3
}
