//
//  SCVector4+Color.swift
//  MatTest
//
//  Created by Cooper Knaak on 1/26/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public extension SCVector4 {
    
    public static var blackColor:SCVector4         { return SCVector4(xValue: 0.0, yValue: 0.0, zValue: 0.0, wValue: 1.0) }
    public static var whiteColor:SCVector4         { return SCVector4(xValue: 1.0, yValue: 1.0, zValue: 1.0, wValue: 1.0) }
    public static var grayColor:SCVector4          { return SCVector4(xValue: 0.5, yValue: 0.5, zValue: 0.5, wValue: 1.0) }
    public static var lightGrayColor:SCVector4     { return SCVector4(x: 2.0 / 3.0, y: 2.0 / 3.0, z: 2.0 / 3.0, w: 1.0) }
    public static var darkGrayColor:SCVector4      { return SCVector4(x: 1.0 / 3.0, y: 1.0 / 3.0, z: 1.0 / 3.0, w: 1.0) }
    
    public static var redColor:SCVector4           { return SCVector4(xValue: 1.0, yValue: 0.0, zValue: 0.0, wValue: 1.0) }
    public static var greenColor:SCVector4         { return SCVector4(xValue: 0.0, yValue: 1.0, zValue: 0.0, wValue: 1.0) }
    public static var blueColor:SCVector4          { return SCVector4(xValue: 0.0, yValue: 0.0, zValue: 1.0, wValue: 1.0) }
    
    public static var darkRedColor:SCVector4       { return SCVector4(xValue: 0.5, yValue: 0.0, zValue: 0.0, wValue: 1.0) }
    public static var darkGreenColor:SCVector4     { return SCVector4(xValue: 0.0, yValue: 0.5, zValue: 0.0, wValue: 1.0) }
    public static var darkBlueColor:SCVector4      { return SCVector4(xValue: 0.0, yValue: 0.0, zValue: 0.5, wValue: 1.0) }
    
    public static var yellowColor:SCVector4        { return SCVector4(xValue: 1.0, yValue: 1.0, zValue: 0.0, wValue: 1.0) }
    public static var magentaColor:SCVector4       { return SCVector4(xValue: 1.0, yValue: 0.0, zValue: 1.0, wValue: 1.0) }
    public static var cyanColor:SCVector4          { return SCVector4(xValue: 0.0, yValue: 1.0, zValue: 1.0, wValue: 1.0) }
    
    public static var orangeColor:SCVector4        { return SCVector4(xValue: 1.0, yValue: 0.5, zValue: 0.0, wValue: 1.0) }
    public static var purpleColor:SCVector4        { return SCVector4(xValue: 0.4, yValue: 0.0, zValue: 0.8, wValue: 1.0) }
    public static var brownColor:SCVector4         { return SCVector4(xValue: 0.4, yValue: 0.2, zValue: 0.0, wValue: 1.0) }
    
    public static var fireColor:SCVector4          { return SCVector4(xValue: 0.9, yValue: 0.4, zValue: 0.2, wValue: 1.0) }
    
    public static var rainbowColors:[SCVector4] {
        return [self.redColor,
            self.orangeColor,
            self.yellowColor,
            self.greenColor,
            self.cyanColor,
            self.blueColor,
            self.purpleColor]
    }
    
    public static func rainbowColorAtIndex(index:Int) -> SCVector4 {
        let rcs = SCVector4.rainbowColors
        return rcs[index % rcs.count]
    }
    
    public static func randomRainbowColor() -> SCVector4 {
        let rcs = SCVector4.rainbowColors
        return rcs[Int(arc4random() % UInt32(rcs.count))]
    }
    
}// SCVector4 + Color (get vector that represents a color)