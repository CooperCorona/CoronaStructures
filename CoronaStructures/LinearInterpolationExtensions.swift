//
//  LinearInterpolationExtensions.swift
//  CoronaStructures
//
//  Created by Cooper Knaak on 9/6/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience

extension CGFloat: Interpolatable {}

extension CGRect {
    
    /**
     Linearly interpolates between the corner of the rectangle.
     - parameters point: A point with x and y coordinates ranging between [0.0, 1.0]
     corresponding to the percentage across the rectangle.
     - returns: The interpolated point inside the rectangle
     */
    public func interpolate(_ point:CGPoint) -> CGPoint {
        return CGPoint(x: linearlyInterpolate(point.x, left: self.minX, right: self.maxX), y: linearlyInterpolate(point.y, left: self.minY, right: self.maxY))
    }
    
    ///Returns a random point in or on the rectangle.
    public func randomPoint() -> CGPoint {
        let xPercent = CGFloat.random()
        let yPercent = CGFloat.random()
        return self.origin + CGPoint(x: xPercent, y: yPercent) * self.size
    }
    
    
}

extension Sequence where Iterator.Element: Interpolatable {
    
    public func average(_ defaultValue:Iterator.Element) -> Iterator.Element {
        var i = 0
        var total = defaultValue
        //Rather than using .reduce, we manually unroll
        //it so we can keep track of the index, which
        //lets us find the count (which sequences don't
        //have to keep track of).
        for value in self {
            total = total + value
            i += 1
        }
        guard i > 0 else {
            return defaultValue
        }
        //Interpolatable only requires that left-scalar-multiplication
        //be defined, so we have to convert our division into multiplication.
        let count = 1.0 / CGFloat(i)
        return count * total
    }
    
}
