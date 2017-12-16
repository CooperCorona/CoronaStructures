//
//  AngleDelta.swift
//  MatTest
//
//  Created by Cooper Knaak on 2/1/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

open class AngleDelta: NSObject {
    
    open class var π:CGFloat { return CGFloat.pi }
    
    open class func incrementAngle(_ startAngle:CGFloat, toAngle endAngle:CGFloat, delta:CGFloat) -> CGFloat {
    
        if (abs(startAngle - endAngle) <= self.π) {
            return self.internalIncrementAngle(startAngle, toAngle: endAngle, delta: delta)
        }
        
        else if (startAngle >= 0.0 && endAngle <= 0.0) {
            return self.internalIncrementAngle(startAngle, toAngle: 2.0 * self.π + endAngle, delta: delta)
        }
        
        else if (startAngle <= 0.0 && endAngle >= 0.0) {
//            return self.internalIncrementAngle(startAngle, toAngle: 2.0 * self.π - endAngle, delta: delta)
            return self.internalIncrementAngle(startAngle, toAngle: endAngle - 2.0 * self.π, delta: delta)
        }
        
        else {
            return self.internalIncrementAngle(startAngle, toAngle: endAngle, delta: delta)
        }
        
    }//increment angle so it gets closer to other angle
    
    fileprivate class func internalIncrementAngle(_ startAngle:CGFloat, toAngle endAngle:CGFloat, delta:CGFloat) -> CGFloat {
        
        var angle = startAngle
            if (abs(angle - endAngle) <= delta / 2.0) {
                return self.constrainAngle(endAngle)
            }
        
        if (startAngle < endAngle) {
            angle += delta
        } else {
            angle -= delta
        }
        
            if (abs(angle - endAngle) <= delta / 2.0) {
                return self.constrainAngle(endAngle)
            }
        
        return angle
    }//increment angle
    
    open class func constrainAngle(_ angle:CGFloat) -> CGFloat {
    
        if (angle > CGFloat.pi) {
            return angle - 2.0 * self.π
        } else if (angle < -CGFloat.pi) {
            return 2.0 * self.π + angle
        } else {
            return angle
        }
        
    }//constrain angle
    
    open class func makePositive(angle input:CGFloat) -> CGFloat {
        var angle = input
        while angle < 0.0 {
            angle += 2.0 * CGFloat.pi
        }
        return angle
    }
    
}

public extension CGFloat {
    
    /** Converts this value from radians to degrees.*/
    public func toDegrees() -> CGFloat {
        return self * 180.0 / CGFloat.pi
    }//convert to degrees
    
}//CGFloat + Convenience
