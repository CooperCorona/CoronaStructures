
//
//  TopRoundedView.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 7/16/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
import UIKit

public class TopRoundedView: UIView {
    
    // MARK: - Properties
    
    public var color:UIColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var borderColor:UIColor? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var borderWidth:CGFloat = 2.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var cornerRadius:CGFloat = 8.0  {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Setup
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.opaque = false
        self.contentMode = .Redraw
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        let colStr = aDecoder.decodeObjectForKey("Color") as! String
        self.color = UIColor(string: colStr)
        if let bColStr = aDecoder.decodeObjectForKey("Border Color") as? String {
            self.borderColor = UIColor(string: bColStr)
        }
        self.borderWidth = CGFloat(aDecoder.decodeDoubleForKey("Border Width"))
        self.cornerRadius = CGFloat(aDecoder.decodeDoubleForKey("Corner Radius"))
        
        super.init(coder: aDecoder)
        
        self.opaque = false
        self.contentMode = .Redraw
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(Double(self.cornerRadius), forKey: "Corner Radius")
        aCoder.encodeDouble(Double(self.borderWidth), forKey: "Border Width")
        
        if let borderColorStr = self.borderColor?.getString() {
            aCoder.encodeObject(borderColorStr, forKey: "Border Color")
        }
//        aCoder.encodeObject(self.borderColor?.getString() ?? "", forKey: "Border Color")
        aCoder.encodeObject(self.color.getString(), forKey: "Color")
    }
    
    // MARK: - Logic
    
    public override func drawRect(rect: CGRect) {
        
        let size = self.frame.size
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        if let borderColor = self.borderColor {
            
            CGContextAddPath(context, TopRoundedView.pathForSize(size, radius: self.cornerRadius, inset: self.borderWidth / 2.0))
            
            CGContextSetFillColorWithColor(context, self.color.CGColor)
            CGContextFillPath(context)
            
            CGContextAddPath(context, TopRoundedView.pathForSize(size, radius: self.cornerRadius, inset: self.borderWidth / 2.0))
            CGContextSetLineWidth(context, self.borderWidth)
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            CGContextStrokePath(context)
        } else {
            CGContextAddPath(context, TopRoundedView.pathForSize(size, radius: self.cornerRadius, inset: 0.0))
            
            CGContextSetFillColorWithColor(context, self.color.CGColor)
            CGContextFillPath(context)
        }
        
        CGContextRestoreGState(context)
    }//draw rect
    
    public class func pathForSize(size:CGSize, radius:CGFloat, inset:CGFloat) -> CGPathRef {
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, size.width / 2.0, inset)
        CGPathAddArcToPoint(path, nil, size.width - inset, inset, size.width - inset, size.height - inset, radius)
        CGPathAddLineToPoint(path, nil, size.width - inset, size.height - inset)
        CGPathAddLineToPoint(path, nil, inset, size.height - inset)
        CGPathAddArcToPoint(path, nil, inset, inset, radius + inset, inset, radius)
        CGPathCloseSubpath(path)
        return path
    }
    
}
#endif