//
//  SCVector3+Color.swift
//  Fields and Forces
//
//  Created by Cooper Knaak on 1/4/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import CoronaConvenience
#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public extension SCVector3 {
    
    public static var blackColor:SCVector3         { return SCVector3(xValue: 0.0, yValue: 0.0, zValue: 0.0) }
    public static var whiteColor:SCVector3         { return SCVector3(xValue: 1.0, yValue: 1.0, zValue: 1.0) }
    public static var grayColor:SCVector3          { return SCVector3(xValue: 0.5, yValue: 0.5, zValue: 0.5) }
    public static var lightGrayColor:SCVector3     { return SCVector3(x: 2.0 / 3.0, y: 2.0 / 3.0, z: 2.0 / 3.0) }
    public static var darkGrayColor:SCVector3      { return SCVector3(x: 1.0 / 3.0, y: 1.0 / 3.0, z: 1.0 / 3.0) }
    
    public static var redColor:SCVector3           { return SCVector3(xValue: 1.0, yValue: 0.0, zValue: 0.0) }
    public static var greenColor:SCVector3         { return SCVector3(xValue: 0.0, yValue: 1.0, zValue: 0.0) }
    public static var blueColor:SCVector3          { return SCVector3(xValue: 0.0, yValue: 0.0, zValue: 1.0) }
    
    public static var darkRedColor:SCVector3       { return SCVector3(xValue: 0.5, yValue: 0.0, zValue: 0.0) }
    public static var darkGreenColor:SCVector3     { return SCVector3(xValue: 0.0, yValue: 0.5, zValue: 0.0) }
    public static var darkBlueColor:SCVector3      { return SCVector3(xValue: 0.0, yValue: 0.0, zValue: 0.5) }
    
    public static var yellowColor:SCVector3        { return SCVector3(xValue: 1.0, yValue: 1.0, zValue: 0.0) }
    public static var magentaColor:SCVector3       { return SCVector3(xValue: 1.0, yValue: 0.0, zValue: 1.0) }
    public static var cyanColor:SCVector3          { return SCVector3(xValue: 0.0, yValue: 1.0, zValue: 1.0) }
    
    public static var orangeColor:SCVector3        { return SCVector3(xValue: 1.0, yValue: 0.5, zValue: 0.0) }
    public static var purpleColor:SCVector3        { return SCVector3(xValue: 0.4, yValue: 0.0, zValue: 0.8) }
    public static var brownColor:SCVector3         { return SCVector3(xValue: 0.4, yValue: 0.2, zValue: 0.0) }
    
    public static var fireColor:SCVector3          { return SCVector3(xValue: 0.9, yValue: 0.4, zValue: 0.2) }
    
    public static var rainbowColors:[SCVector3] {
        return [self.redColor,
                self.orangeColor,
                self.yellowColor,
                self.greenColor,
                self.cyanColor,
                self.blueColor,
                self.purpleColor]
    }
    
    public static func rainbowColorAtIndex(_ index:Int) -> SCVector3 {
        let rcs = SCVector3.rainbowColors
        return rcs[index % rcs.count]
    }
    
    public static func randomRainbowColor() -> SCVector3 {
        let rcs = SCVector3.rainbowColors
        return rcs[Int(arc4random() % UInt32(rcs.count))]
    }
    
    public static var fireColors = [
        SCVector3.fireColor,
        SCVector3(x: 0.9, y: 0.2, z: 0.4),
        SCVector3(x: 0.4, y: 0.9, z: 0.2),
        SCVector3(x: 0.2, y: 0.9, z: 0.4),
        SCVector3(x: 0.4, y: 0.2, z: 0.9),
        SCVector3(x: 0.2, y: 0.4, z: 0.9)
    ]
    public static func randomFireColor() -> SCVector3 {
        return SCVector3.fireColors.randomElement()!
    }
    
}// SCVector3 + Color (get vector that represents a color)
