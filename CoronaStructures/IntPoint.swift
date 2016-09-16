//
//  IntPoint.swift
//  KingOfKauffman
//
//  Created by Cooper Knaak on 11/23/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public struct IntPoint: CustomStringConvertible, Hashable {
    
    // MARK: - Properties
    
    public var x = 0
    public var y = 0
    public var description:String { return "(\(self.x), \(self.y))" }
    public var hashValue:Int { return self.x << 16 | self.y }
    
    // MARK: - Setup
    
    public init() {
        
    }
    
    public init(x:Int, y:Int) {
        self.x = x
        self.y = y
    }
    
    public init(x:Int) {
        self.x = x
    }
    
    public init(y:Int) {
        self.y = y
    }
    
    public init(xy:Int) {
        self.x = xy
        self.y = xy
    }
    
    public init(point:CGPoint) {
        self.x = Int(point.x)
        self.y = Int(point.y)
    }
    
    public init(string:String) {
        #if os(iOS)
        self.init(point: CGPointFromString(string))
        #else
        self.init(point: NSPointFromString(string))
        #endif
    }
    
    // MARK: - Logic
    
    ///Returns true if 0 <= x < width and 0 <= y < height.
    public func withinGridWidth(_ width:Int, height:Int) -> Bool {
        return 0 <= self.x && self.x < width && 0 <= self.y && self.y < height
    }
    
    public func getCGPoint() -> CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
    
    public func getString() -> String {
        #if os(iOS)
        return NSStringFromCGPoint(self.getCGPoint()) as String
        #else
        return NSStringFromPoint(self.getCGPoint()) as String
        #endif
    }
    
    ///Uses manhattan distance, becaase euclidian distance just doesn't make sense.
    public func distance(_ point:IntPoint) -> Int {
        return abs(point.x - self.x) + abs(point.y - self.y)
    }

    /**
     The Von-neumann neighborhood is the right, up, left, and down tiles.
     - returns: An array of IntPoints representing the offset between a point
     and its Von-neumann neighborhood.
     */
    public static func neumannTiles() -> [IntPoint] {
        return [
            IntPoint(x: +1, y: +0),
            IntPoint(x: +0, y: +1),
            IntPoint(x: -1, y: +0),
            IntPoint(x: +0, y: -1)
        ]
    }
    
    /**
     The Von-neumann neighborhood is the right, up, left, and down tiles.
     - returns: The points in this point's Von-neumann neighborhood.
     */
    public func neumannNeighbors() -> [IntPoint] {
        return IntPoint.neumannTiles().map() { self + $0 }
    }
    
    /**
     The Moore neighborhood is the right, up, left, down, and diagonal tiles.
     - returns: An array of IntPoints representing the offset between a point
     and its Moore neighborhood.
     */
    public static func mooreTiles() -> [IntPoint] {
        return [
            IntPoint(x: +1, y: +0),
            IntPoint(x: +1, y: +1),
            IntPoint(x: +0, y: +1),
            IntPoint(x: -1, y: +1),
            IntPoint(x: -1, y: +0),
            IntPoint(x: -1, y: -1),
            IntPoint(x: +0, y: -1),
            IntPoint(x: +1, y: -1)
        ]
    }
    
    /**
     The Moore neighborhood is the right, up, left, down, and diagonal tiles.
     - returns: The points in this point's Moore neighborhood.
     */
    public func mooreNeighbors() -> [IntPoint] {
        return IntPoint.mooreTiles().map() { self + $0 }
    }

    public static func iterateRectangle(_ size:IntPoint, handler:(IntPoint) -> Void) {
        for j in 0..<size.y {
            for i in 0..<size.x {
                handler(IntPoint(x: i, y: j))
            }
        }
    }
    
    public static func iterateWidth(_ width:Int, height:Int, handler:(IntPoint) -> Void) {
        return IntPoint.iterateRectangle(IntPoint(x: width, y: height), handler: handler)
    }
}
