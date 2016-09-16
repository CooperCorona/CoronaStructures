//
//  SCVector4.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/13/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public struct SCVector4: CustomStringConvertible {
    
    // MARK: - Properties
    
    public var x:CGFloat
    public var y:CGFloat
    public var z:CGFloat
    public var w:CGFloat
    
    public var r:CGFloat {
        
        get {
            return x
        }
        
    }//r
    
    public var g:CGFloat {
        
        get {
            return y
        }
        
    }//g
    
    public var b:CGFloat {
        
        get {
            return z
        }
        
    }//b
    
    public var a:CGFloat {
        
        get {
            return w
        }
        
    }//a
    
    public var xyz:SCVector3 { return SCVector3(x: self.x, y: self.y, z: self.z) }
    
    // MARK: - Setup
    
    //Initialization
    public init(xValue:CGFloat, yValue:CGFloat, zValue:CGFloat, wValue:CGFloat = 1.0) {
        x = xValue
        y = yValue
        z = zValue
        w = wValue
    }//initialize
    
    public init(x:CGFloat, y:CGFloat, z:CGFloat, w:CGFloat = 1.0) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    public init(vector3:SCVector3, wValue:CGFloat=1.0) {
        self.init(xValue: vector3.x, yValue: vector3.y, zValue: vector3.z, wValue: wValue)
    }//initialize
    
    public init(gray:CGFloat, w:CGFloat = 1.0) {
        self.init(x: gray, y: gray, z: gray, w: w)
    }
    
    public init(values:(CGFloat, CGFloat, CGFloat, CGFloat)) {
        self.init(xValue: values.0, yValue: values.1, zValue: values.2, wValue: values.3)
    }//initialize
    
    public init(string:String) {
        
        let comps = (string as NSString).components(separatedBy: ", ")
        if (comps.count >= 3) {
            
            let x = comps[0].getCGFloatValue()
            let y = comps[1].getCGFloatValue()
            let z = comps[2].getCGFloatValue()
            
            var w:CGFloat = 1.0
            if (comps.count >= 4) {
                w = comps[3].getCGFloatValue()
            }
            
            self.init(xValue: CGFloat(x), yValue: CGFloat(y), zValue: CGFloat(z), wValue: CGFloat(w))
            
        } else {
            
            self.init()
        }
        
    }//initialize with a string
    
    public init() {
        self.init(xValue: 0.0, yValue: 0.0, zValue: 0.0, wValue: 0.0)
    }//initialize (default)
    
    // MARK: - Logic
    
    //Vector Functions
    public func length() -> CGFloat {
        return sqrt(x * x + y * y + z * z + w * w)
    }//get length
    
    public func normalize() -> SCVector4 {
        let l = length()
        return SCVector4(xValue: x / l, yValue: y / l, zValue: z / l, wValue: w / l)
    }//get normalized vector
    
    public func dot(_ dotBy:SCVector4) -> CGFloat {
        return x * dotBy.x + y * dotBy.y + z * dotBy.z + w * dotBy.w
    }//compute dot product
    
    public func getTuple() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        return (x, y, z, w)
    }//get as tuple
    
    public func getGLTuple() -> (GLfloat, GLfloat, GLfloat, GLfloat) {
        return (GLfloat(x), GLfloat(y), GLfloat(z), GLfloat(w))
    }//get vector as GLfloat tuple
    
    //CustomStringConvertible Protocol
    public var description:String {
        
        get {
            return "{\(x), \(y), \(z), \(w)}"
        }
    }
}

// MARK: - OpenGL
extension SCVector4 {
    
    public func bindGLClearColor() {
        glClearColor(GLfloat(self.x), GLfloat(self.y), GLfloat(self.z), GLfloat(self.w))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    public func getGLComponents() -> [GLfloat] {
        return [GLfloat(self.x), GLfloat(self.y), GLfloat(self.z), GLfloat(self.w)]
    }
    
}


//Operations
public func +(left:SCVector4, right:SCVector4) -> SCVector4 {
    return SCVector4(xValue: left.x + right.x, yValue: left.y + right.y, zValue: left.z + right.z, wValue: left.w + right.w)
}//plus

public func -(left:SCVector4, right:SCVector4) -> SCVector4 {
    return SCVector4(xValue: left.x - right.x, yValue: left.y - right.y, zValue: left.z - right.z, wValue: left.w - right.w)
}//minus

public func *(left:SCVector4, right:SCVector4) -> SCVector4 {
    return SCVector4(xValue: left.x * right.x, yValue: left.y * right.y, zValue: left.z * right.z, wValue: left.w * right.w)
}//times

public func /(left:SCVector4, right:SCVector4) -> SCVector4 {
    return SCVector4(xValue: left.x / right.x, yValue: left.y / right.y, zValue: left.z / right.z, wValue: left.w / right.w)
}//divide


//Equals
public func +=(left:inout SCVector4, right:SCVector4) {
    left = left + right
}//plus

public func -=(left:inout SCVector4, right:SCVector4) {
    left = left - right
}//minus

public func *=(left:inout SCVector4, right:SCVector4) {
    left = left * right
}//times

public func /=(left:inout SCVector4, right:SCVector4) {
    left = left / right
}//divide


//Scalar
public func +(left:SCVector4, right:CGFloat) -> SCVector4 {
    return SCVector4(xValue: left.x + right, yValue: left.y + right, zValue: left.z + right, wValue: left.w + right)
}//plus

public func -(left:SCVector4, right:CGFloat) -> SCVector4 {
    return SCVector4(xValue: left.x - right, yValue: left.y - right, zValue: left.z - right, wValue: left.w - right)
}//minus

public func *(left:SCVector4, right:CGFloat) -> SCVector4 {
    return SCVector4(xValue: left.x * right, yValue: left.y * right, zValue: left.z * right, wValue: left.w * right)
}//times

public func /(left:SCVector4, right:CGFloat) -> SCVector4 {
    return SCVector4(xValue: left.x / right, yValue: left.y / right, zValue: left.z / right, wValue: left.w / right)
}//divide

public func +(right:CGFloat, left:SCVector4) -> SCVector4 {
    return SCVector4(xValue: left.x + right, yValue: left.y + right, zValue: left.z + right, wValue: left.w + right)
}//plus

public func -(right:CGFloat, left:SCVector4) -> SCVector4 {
    return SCVector4(xValue: left.x - right, yValue: left.y - right, zValue: left.z - right, wValue: left.w - right)
}//minus

public func *(right:CGFloat, left:SCVector4) -> SCVector4 {
    return SCVector4(xValue: left.x * right, yValue: left.y * right, zValue: left.z * right, wValue: left.w * right)
}//times

public func /(right:CGFloat, left:SCVector4) -> SCVector4 {
    return SCVector4(xValue: left.x / right, yValue: left.y / right, zValue: left.z / right, wValue: left.w / right)
}//divide


//Scalar Equals
public func +=(left:inout SCVector4, right:CGFloat) {
    left = left + right
}//plus

public func -=(left:inout SCVector4, right:CGFloat) {
    left = left - right
}//minus

public func *=(left:inout SCVector4, right:CGFloat) {
    left = left * right
}//times

public func /=(left:inout SCVector4, right:CGFloat) {
    left = left / right
}//divide

// MARK: - Approximately Equals

public func ~=(left:SCVector4, right:SCVector4) -> Bool {
    
//    let epsilon:CGFloat = 0.001
    
    return  left.x ~= right.x &&
            left.y ~= right.y &&
            left.z ~= right.z &&
            left.w ~= right.w
}//about equals operator
