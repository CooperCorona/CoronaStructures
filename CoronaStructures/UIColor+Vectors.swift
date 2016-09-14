//
//  UIColor+Vectors.swift
//  CoronaStructures
//
//  Created by Cooper Knaak on 9/6/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

    
#if os(iOS)
import UIKit
public typealias ColorType = UIColor
#else
import Cocoa
public typealias ColorType = NSColor
#endif
    
extension ColorType {
    
    public convenience init(vector3:SCVector3) {
        self.init(red: vector3.r, green: vector3.g, blue: vector3.b, alpha: 1.0)
    }//initialize
    
    public convenience init(vector4:SCVector4) {
        self.init(red: vector4.r, green: vector4.g, blue: vector4.b, alpha: vector4.a)
    }//initialize
    
    public func getVector3() -> SCVector3 {
        
        let comps = self.getComponents()
        
        return SCVector3(xValue: comps[0], yValue: comps[1], zValue: comps[2])
        
    }//get SCVector3
    
    public func getVector4() -> SCVector4 {
        
        let comps = self.getComponents()
        
        return SCVector4(xValue: comps[0], yValue: comps[1], zValue: comps[2], wValue: comps[3])
        
    }//get SCVector4
    
}