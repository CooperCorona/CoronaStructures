//
//  CGFloat+Random.swift
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

// MARK: - Random

extension CGFloat {
    
    public static func random() -> CGFloat {
        return CGFloat(drand48())
    }
    
    public static func randomBetween(_ lower:CGFloat, and upper:CGFloat) -> CGFloat {
        return linearlyInterpolate(CGFloat.random(), left: lower, right: upper)
    }
    
    public static func randomMiddle(_ middle:CGFloat, range:CGFloat) -> CGFloat {
        return linearlyInterpolate(CGFloat.random(), left: middle - range / 2.0, right: middle + range / 2.0)
    }

    public static func randomAngle() -> CGFloat {
        return CGFloat.randomMiddle(0.0, range: 2.0 * CGFloat.pi)
    }
    
}
