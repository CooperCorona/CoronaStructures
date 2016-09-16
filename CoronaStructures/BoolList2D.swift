//
//  BoolList2D.swift
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

public struct BoolList2D: CustomStringConvertible {
    
    // MARK: - Properties
    
    fileprivate var tiles:[UInt32]
    public let width:Int
    public let height:Int
    
    public var description:String { return "\(self.tiles)" }
    
    // MARK: - Setup
    
    public init(width:Int, height:Int) {
        
        self.width      = width
        self.height     = height
        
        let tileCount   = Int(ceil(CGFloat(self.width * self.height) / 32.0))
        self.tiles      = [UInt32](repeating: 0, count: tileCount)
        
    }
    
    public init?(contentsOfURL url:URL) {
        guard let dict = NSDictionary(contentsOf: url) else {
            return nil
        }
        
        guard let widthString = dict["width"] as? String, let heightString = dict["height"] as? String, let array = dict["array"] as? [NSNumber] else {
            return nil
        }
        
        guard let width = Int(widthString), let height = Int(heightString) else {
            return nil
        }
        
        self.width  = width
        self.height = height
        self.tiles  = array.map() { $0.uint32Value }
    }
    
    public init?(contentsOfFile file:String) {
        let url = URL.URLForPath(file, pathExtension: "plist")
        self.init(contentsOfURL: url)
    }
    
    // MARK: - Accessors
    
    public func scalarIndexForPoint(_ point:IntPoint) -> Int {
        return point.y * self.width + point.x
    }
    
    public func bitIndicesForIndex(_ index:Int) -> (arrayIndex:Int, bitIndex:UInt32) {
        return (index / 32, UInt32(1) << UInt32(index % 32))
    }
    
    public func bitIndicesForPoint(_ point:IntPoint) -> (arrayIndex:Int, bitIndex:UInt32) {
        return self.bitIndicesForIndex(self.scalarIndexForPoint(point))
    }
    
    public subscript(x:Int, y:Int) -> Bool {
        get {
            let indices = self.bitIndicesForPoint(IntPoint(x: x, y: y))
            return self.tiles[indices.arrayIndex] & indices.bitIndex != 0
        }
        set {
            let indices = self.bitIndicesForPoint(IntPoint(x: x, y: y))
            if newValue {
                self.tiles[indices.arrayIndex] = self.tiles[indices.arrayIndex] | UInt32(indices.bitIndex)
            } else {
                self.tiles[indices.arrayIndex] &= UInt32(~indices.bitIndex)
            }
        }
    }
    
    ///Gets a dictionary of the properties suitable for saving and loading a BoolList2D.
    public func getDictionary() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["width"]   = "\(self.width)"
        dict["height"]  = "\(self.height)"
        dict["array"]   = self.tiles.map() { NSNumber(value: $0 as UInt32) }
        return dict
    }
    
    ///Writes the dictionary to a give file.
    public func writeToFile(_ file:String) -> Bool {
        let url = URL.URLForPath(file, pathExtension: "plist")
        return self.getDictionary().write(to: url, atomically: true)
    }
    
}
