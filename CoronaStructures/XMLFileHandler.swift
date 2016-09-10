//
//  XMLFileHandler.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 12/10/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public typealias XMLDictionary = [String:String]

@objc public protocol XMLFileHandlerDelegate {
    
    func startElement(elementName:String, attributes:XMLDictionary)
    optional func endElement(elementName:String)
    
    optional func handleVariable(attributes:XMLDictionary)
    
    optional func finishedParsing()
    
    optional func documentEnded()
    
}


public class XMLFileHandler: NSObject, NSXMLParserDelegate {
    
    unowned let delegate:XMLFileHandlerDelegate
    
    public var parser:NSXMLParser? = nil
    public var parseIndex = 0
    
    public let files:[String]
    public let directory:String?
    
    public var variables:[String:String] = ["π":"3.14159"]
    
    
    public init(files:[String], directory:String?, delegate:XMLFileHandlerDelegate) {
        
        self.delegate = delegate
        
        self.files = files
        self.directory = directory
        
        super.init()
        
    }//initialize
    
    public convenience init(file:String, directory:String?, delegate:XMLFileHandlerDelegate) {
        self.init(files:[file], directory:directory, delegate:delegate)
    }//initialize
    
    public func loadFile() {
        
        while (self.parseIndex < self.files.count) {
            
            let path = XMLFileHandler.pathForFile(files[parseIndex], directory: directory, fileExtension: "xml")
            let pathWithoutDirectory = NSBundle.mainBundle().pathForResource(files[parseIndex], ofType: "xml")
            
            if let data = NSData(contentsOfFile: path) {
                
                self.parseData(data)
                
            } else if let bundlePath = pathWithoutDirectory {
                
                if let data = NSData(contentsOfFile: bundlePath) {
                    
                    
                    self.parseData(data)
                    
                }
                
            }
            
            self.parseIndex += 1
        }//valid file to load
        
        self.delegate.finishedParsing?()
        
    }//load file
    
    public func parseData(data:NSData) {
        
        self.parser = NSXMLParser(data: data)
        
        if let validParser = self.parser {
            
            validParser.delegate = self
            
            if (!validParser.parse()) {
                self.parserDidEndDocument(validParser)
            }//failed to parse
            
        }//parser is valid
        
    }//parse data
    
    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
//        let aDict = attributeDict.map() { (keyValue:(String, String)) -> (NSObject, AnyObject) in return (keyValue.0, keyValue.1) }
        
        if (elementName == "Variable") {
            self.handleVariable(attributeDict)
            
            self.delegate.handleVariable?(attributeDict)
            return
        }
        
        self.delegate.startElement(elementName, attributes: attributeDict)
        
    }
    
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if (elementName == "Variable") {
            return
        }
        
        self.delegate.endElement?(elementName)
    }
    
    public func parserDidEndDocument(parser: NSXMLParser) {
        self.delegate.documentEnded?()
    }//parser did end document
    
    public class func pathForFile(file:String, directory:String?, fileExtension:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectoryPath = paths[0] as NSString
        
        var filePath = documentDirectoryPath
        
        if let validDirectory = directory {
            filePath = filePath.stringByAppendingPathComponent(validDirectory)
        }
        
        filePath = filePath.stringByAppendingPathComponent(file)
        filePath = filePath.stringByAppendingPathExtension(fileExtension)!
        
        return filePath as String
    }//get path
    
    
    public func handleVariable(attributes:XMLDictionary) {
        
        let name = attributes["name"]!
        let value = attributes["value"]!
        
        self.variables[name] = value
    }//handle variables
    
    public subscript(key:String) -> String? {
        get {
            return self.variables[key]
        }
        set {
            self.variables[key] = newValue
        }
    }
    
    public class func convertDictionary(dict:[NSObject:AnyObject]) -> XMLDictionary {
        var d:XMLDictionary = [:]
        for case let (key as String, value as String) in dict {
            d[key] = value
        }
        return d
    }
    
}

public extension XMLFileHandler {
    
    public class func convertStringToVector3(str:String) -> SCVector3 {
        
        let comps = str.componentsSeparatedByString(", ")
        
        let x = CGFloat((comps[0] as NSString).doubleValue)
        let y = CGFloat((comps[1] as NSString).doubleValue)
        let z = CGFloat((comps[2] as NSString).doubleValue)
        
        return SCVector3(values: (x, y, z))
    }//convert string to vector 3
    
    public class func convertStringToVector4(str:String) -> SCVector4 {
        
        let comps = str.componentsSeparatedByString(", ")
        
        let x = CGFloat((comps[0] as NSString).doubleValue)
        let y = CGFloat((comps[1] as NSString).doubleValue)
        let z = CGFloat((comps[2] as NSString).doubleValue)
        let w = CGFloat((comps[3] as NSString).doubleValue)
        
        return SCVector4(values: (x, y, z, w))
    }//convert string to vector 3
    
}// Converting Strings
