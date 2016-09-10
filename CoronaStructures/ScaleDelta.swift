//
//  ScaleDelta.swift
//  Gravity
//
//  Created by Cooper Knaak on 4/18/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience

public class ScaleDelta: NSObject {
   
    // MARK: - Properties
    
    private var initialScale:CGFloat = 1.0
    private var internalScale:CGFloat = 1.0
    public var currentScale:CGFloat { return self.internalScale }
    
    public var minimumScale:CGFloat = 0.0 {
        didSet {
            if (self.internalScale < self.minimumScale) {
                self.internalScale = self.minimumScale
            }
        }
    }
    public var maximumScale:CGFloat = 1.0 {
        didSet {
            if (self.internalScale < self.maximumScale) {
                self.internalScale = self.maximumScale
            }
        }
    }
    
    ///A float value in range [0.0, 1.0] to scale, where 0.0 maps to *minimumScale* and 1.0 maps to *maximumScale*.
    ///Values in between are linearly interpolated (if *minimumScale* == *maximumScale*, value is 1.0).
    public var percent:CGFloat {
        get {
            if self.minimumScale ~= self.maximumScale {
                return 1.0
            } else {
                return (self.internalScale - self.minimumScale) / (self.maximumScale - self.minimumScale)
            }
        }
    }
    
    // MARK: - Setup
    
    public init(scale:CGFloat) {
        
        self.initialScale = scale
        self.internalScale = scale
        
        super.init()
        
    }//initialize with default scale
    
    // MARK: - Logic
    
    #if os(iOS)
    public func handlePinch(sender:UIPinchGestureRecognizer) {
        
        switch sender.state {
        case .Began, .Changed:
            self.internalScale = self.initialScale * sender.scale
            break
        case .Ended, .Cancelled:
            self.initialScale = self.internalScale
            break
        default:
            break
        }
        
        self.internalScale = min(max(self.internalScale, self.minimumScale), self.maximumScale)
    }//handle pinch
    #endif
    
    public func setExtremaWithSize(size:CGSize, inSize:CGSize) {
        
        if size.width <= inSize.width && size.height <= inSize.height {
            self.minimumScale = 1.0
            self.maximumScale = 1.0
        }
        self.minimumScale = min((inSize / size).minimum, 1.0)
    }
}
