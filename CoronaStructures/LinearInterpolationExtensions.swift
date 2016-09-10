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
    public func interpolate(point:CGPoint) -> CGPoint {
        return CGPoint(x: linearlyInterpolate(point.x, left: self.minX, right: self.maxX), y: linearlyInterpolate(point.y, left: self.minY, right: self.maxY))
    }
    
    ///Returns a random point in or on the rectangle.
    public func randomPoint() -> CGPoint {
        let xPercent = CGFloat.random()
        let yPercent = CGFloat.random()
        return self.origin + CGPoint(x: xPercent, y: yPercent) * self.size
    }
    
    
}