//
//  RotationDelta.swift
//  MatTest
//
//  Created by Cooper Knaak on 1/28/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public typealias Rotation = (angle:CGFloat, vector:SCVector3)
public typealias TwoStepRotation = (first:Rotation, second:Rotation?)

public class RotationDelta: NSObject {

    public let startRotation:Rotation
    public let endRotation:Rotation
    public let deltaRotation:Rotation
    public let duration:CGFloat
    private var time:CGFloat = 0.0
    public var percent:CGFloat { return self.time / self.duration }
    
    private var finished = false
    public var isFinished:Bool { return self.finished }
    
    public init(start:Rotation, end:Rotation, duration:CGFloat) {
        
        self.startRotation = start
        self.endRotation = end
        self.duration = duration
        self.deltaRotation = (end.angle - start.angle, end.vector - start.vector)
        
        super.init()
        
    }//initialize
    
    public func update(dt:CGFloat) -> Rotation {
        self.time += dt

        if (self.time >= self.duration) {
            self.finished = true
        }
        
        return self.getRotation()
    }//update and get rotation
    
    public func getRotation() -> Rotation {
        let angle = self.startRotation.angle + self.deltaRotation.angle * self.percent
        let vector = self.startRotation.vector + self.deltaRotation.vector * self.percent
        return (angle, vector)
    }
    
    public class func incrementVector(start:SCVector3, toVector end:SCVector3, deltaAngle:CGFloat) -> SCVector3 {
        
        let startLength = start.length()
        let endLength = end.length()
        
        if (startLength <= 0.001 || endLength <= 0.001) {
            return end
        }//one vector is invalid
        
        let angleBetween = acos(start.dot(end) / start.length() / end.length())
        
        if (abs(angleBetween) <= deltaAngle / 2.0) {
            
            return end
            
        }//finished
        
        let normalVector = start.cross(end)
        let rotation = ((angleBetween >= 0.0) ? deltaAngle : -deltaAngle, normalVector)
        
        let currentVector = rotation * start
        
        return currentVector
    }//increment vector towards vector
    
    public class func rotationForString(string:String) -> Rotation {
        
        let comps = string.componentsSeparatedByString(", ") as [NSString]
        
        if (comps.count <= 3) {
            return (0.0, SCVector3.k)
        } else if (comps.count == 8) {
            
            let twoRot = RotationDelta.twoStepRotationForString(string)
            if let secondRot = twoRot.second {
                return twoRot.first * secondRot
            } else {
                return twoRot.first
            }
            
        }//two-step rotation concatenated into 1 rotation
        
        let angle = CGFloat(comps[0].floatValue)
        let x = CGFloat(comps[1].floatValue)
        let y = CGFloat(comps[2].floatValue)
        let z = CGFloat(comps[3].floatValue)
        
        return (angle, SCVector3(xValue: x, yValue: y, zValue: z))
    }//get rotation for string
    
    public class func twoStepRotationForString(string:String) -> TwoStepRotation {
        
        let comps = string.componentsSeparatedByString(", ") as [NSString]
        
        if (comps.count < 8) {
            return (self.rotationForString(string), nil)
        }//not enough components
        
        let angle1 = CGFloat(comps[0].floatValue)
        let x1 = CGFloat(comps[1].floatValue)
        let y1 = CGFloat(comps[2].floatValue)
        let z1 = CGFloat(comps[3].floatValue)
        let angle2 = CGFloat(comps[4].floatValue)
        let x2 = CGFloat(comps[5].floatValue)
        let y2 = CGFloat(comps[6].floatValue)
        let z2 = CGFloat(comps[7].floatValue)
        
        let r1 = (angle1, SCVector3(xValue: x1, yValue: y1, zValue: z1))
        let r2 = (angle2, SCVector3(xValue: x2, yValue: y2, zValue: z2))
        
        return (r1, r2)
    }//get two setp rotation for string
    
}


public func *(lhs:Rotation, rhs:SCVector3) -> SCVector3 {
    return SCMatrix4(rotation: lhs) * rhs
}

public func *(lhs:SCVector3, rhs:Rotation) -> SCVector3 {
    return rhs * lhs
}

public func *(lhs:Rotation, rhs:Rotation) -> Rotation {
     let matrix = SCMatrix4(rotation: lhs).rotate(rhs)
    return matrix.getRotation()
    /*
     *  The previous method caused gimbal lock:
     *  if the first rotation caused the vector
     *  to be parallel to the second rotation,
     *  then ViewMatrix.aimAtVector() wouldn't
     *  pick this up. Therefore, I use the new
     *  SCMatrix4.getRotation() method instead
     *
    public let finalVector = SCMatrix4(rotation: lhs).rotate(rhs.angle, about: rhs.vector) * -SCVector3.k
    
    //aimAtVector uses -k, so by rotating initial value of -k,
    //you return the necessary Rotation to reach the final vector
    return ViewMatrix.aimAtVector(finalVector)
    */
}