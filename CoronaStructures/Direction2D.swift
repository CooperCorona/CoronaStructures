//
//  Direction2D.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 6/18/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public enum Direction2D: String, CustomStringConvertible {
    case Right  = "Right"
    case Up     = "Up"
    case Left   = "Left"
    case Down   = "Down"
    
    public var integerValue:Int {
        switch self {
        case .Right:
            return 0
        case .Up:
            return 1
        case .Left:
            return 2
        case .Down:
            return 3
        }
    }
    
    public var angle:CGFloat {
        switch self {
        case .Right:
            return 0.0
        case .Up:
            return +CGFloat(M_PI) / 2.0
        case .Left:
            return +CGFloat(M_PI)
        case .Down:
            return -CGFloat(M_PI) / 2.0
        }
    }
    public var vector:CGPoint {
        switch self {
        case .Right:
            return CGPoint(x: +1.0, y: +0.0)
        case .Up:
            return CGPoint(x: +0.0, y: +1.0)
        case .Left:
            return CGPoint(x: -1.0, y: +0.0)
        case .Down:
            return CGPoint(x: +0.0, y: -1.0)
        }
    }
    public var integerVector:IntPoint {
        return IntPoint(point: self.vector)
    }
    
    public var next:Direction2D {
        switch self {
        case .Right:
            return .Up
        case .Up:
            return .Left
        case .Left:
            return .Down
        case .Down:
            return .Right
        }
    }
    public var previous:Direction2D {
        switch self {
        case .Right:
            return .Down
        case .Up:
            return .Right
        case .Left:
            return .Up
        case .Down:
            return .Left
        }
    }
    public var opposite:Direction2D {
        switch self {
        case .Right:
            return .Left
        case .Up:
            return .Down
        case .Left:
            return .Right
        case .Down:
            return .Up
        }
    }
    
    public init(integer:Int) {
        switch integer % 4 {
        case 0:
            self = .Right
        case 1:
            self = .Up
        case 2:
            self = .Left
        case 3:
            self = .Down
        default:
            //Will never happen, because
            //Int % 4 is always either
            //0, 1, 2, or 3
            self = .Right
        }
    }
    
    public static let allValues:[Direction2D] = [.Right, .Up, .Left, .Down]
    
    
    
    public var description:String { return self.rawValue }
    
}
