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

// MARK: - Interpolatable Protocol

public protocol Interpolatable {
    func *(_: CGFloat, _: Self) -> Self
    func +(_: Self, _: Self) -> Self
    func -(_: Self, _: Self) -> Self
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
public func linearlyInterpolate<T: Interpolatable>(midX:CGFloat, left:T, right:T) -> T {
    return (1.0 - midX) * left + midX * right
}

// MARK: - Bilinear Interpolation (2D)

public func bilinearlyInterpolate<T: Interpolatable>(mid:CGPoint, leftBelow:T, rightBelow:T, leftAbove:T, rightAbove:T) -> T {
    
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
public func bilinearlyInterpolate<T: Interpolatable>(mid:CGPoint, values:[T]) -> T? {
    if (values.count < 4) {
        return nil
    }
    
    return bilinearlyInterpolate(mid, leftBelow: values[0], rightBelow: values[1], leftAbove: values[2], rightAbove: values[3])
}

// MARK: - Trilinear Interpolation (3D)
public func trilinearlyInterpolate<T: Interpolatable>(mid:SCVector3, leftBelowBehind:T, rightBelowBehind:T, leftAboveBehind:T, rightAboveBehind:T, leftBelowFront:T, rightBelowFront:T, leftAboveFront:T, rightAboveFront:T) -> T {
    
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
public func trilinearlyInterpolate<T: Interpolatable>(mid:SCVector3, values:[T]) -> T? {
    if (values.count < 8) {
        return nil
    }
    
    return trilinearlyInterpolate(mid, leftBelowBehind: values[0], rightBelowBehind: values[1], leftAboveBehind: values[2], rightAboveBehind: values[3], leftBelowFront: values[4], rightBelowFront: values[5], leftAboveFront: values[6], rightAboveFront: values[7])
}
