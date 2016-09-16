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
    
    func startElement(_ elementName:String, attributes:XMLDictionary)
    @objc optional func endElement(_ elementName:String)
    
    @objc optional func handleVariable(_ attributes:XMLDictionary)
    
    @objc optional func finishedParsing()
    
    @objc optional func documentEnded()
    
}


open class XMLFileHandler: NSObject, XMLParserDelegate {
    
    unowned let delegate:XMLFileHandlerDelegate
    
    open var parser:XMLParser? = nil
    open var parseIndex = 0
    
    open let files:[String]
    open let directory:String?
    
    open var variables:[String:String] = ["π":"3.14159"]
    
    
    public init(files:[String], directory:String?, delegate:XMLFileHandlerDelegate) {
        
        self.delegate = delegate
        
        self.files = files
        self.directory = directory
        
        super.init()
        
    }//initialize
    
    public convenience init(file:String, directory:String?, delegate:XMLFileHandlerDelegate) {
        self.init(files:[file], directory:directory, delegate:delegate)
    }//initialize
    
    open func loadFile() {
        
        while (self.parseIndex < self.files.count) {
            
            let path = XMLFileHandler.pathForFile(files[parseIndex], directory: directory, fileExtension: "xml")
            let pathWithoutDirectory = Bundle.main.path(forResource: files[parseIndex], ofType: "xml")
            
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                
                self.parseData(data)
                
            } else if let bundlePath = pathWithoutDirectory {
                
                if let data = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)) {
                    
                    
                    self.parseData(data)
                    
                }
                
            }
            
            self.parseIndex += 1
        }//valid file to load
        
        self.delegate.finishedParsing?()
        
    }//load file
    
    open func parseData(_ data:Data) {
        
        self.parser = XMLParser(data: data)
        
        if let validParser = self.parser {
            
            validParser.delegate = self
            
            if (!validParser.parse()) {
                self.parserDidEndDocument(validParser)
            }//failed to parse
            
        }//parser is valid
        
    }//parse data
    
    open func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
//        let aDict = attributeDict.map() { (keyValue:(String, String)) -> (NSObject, AnyObject) in return (keyValue.0, keyValue.1) }
        
        if (elementName == "Variable") {
            self.handleVariable(attributeDict)
            
            self.delegate.handleVariable?(attributeDict)
            return
        }
        
        self.delegate.startElement(elementName, attributes: attributeDict)
        
    }
    
    open func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if (elementName == "Variable") {
            return
        }
        
        self.delegate.endElement?(elementName)
    }
    
    open func parserDidEndDocument(_ parser: XMLParser) {
        self.delegate.documentEnded?()
    }//parser did end document
    
    open class func pathForFile(_ file:String, directory:String?, fileExtension:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectoryPath = paths[0] as NSString
        
        var filePath = documentDirectoryPath
        
        if let validDirectory = directory {
            filePath = filePath.appendingPathComponent(validDirectory) as NSString
        }
        
        filePath = filePath.appendingPathComponent(file) as NSString
        filePath = filePath.appendingPathExtension(fileExtension)! as NSString
        
        return filePath as String
    }//get path
    
    
    open func handleVariable(_ attributes:XMLDictionary) {
        
        let name = attributes["name"]!
        let value = attributes["value"]!
        
        self.variables[name] = value
    }//handle variables
    
    open subscript(key:String) -> String? {
        get {
            return self.variables[key]
        }
        set {
            self.variables[key] = newValue
        }
    }
    
    open class func convertDictionary(_ dict:[AnyHashable: Any]) -> XMLDictionary {
        var d:XMLDictionary = [:]
        for case let (key as String, value as String) in dict {
            d[key] = value
        }
        return d
    }
    
}

public extension XMLFileHandler {
    
    public class func convertStringToVector3(_ str:String) -> SCVector3 {
        
        let comps = str.components(separatedBy: ", ")
        
        let x = CGFloat((comps[0] as NSString).doubleValue)
        let y = CGFloat((comps[1] as NSString).doubleValue)
        let z = CGFloat((comps[2] as NSString).doubleValue)
        
        return SCVector3(values: (x, y, z))
    }//convert string to vector 3
    
    public class func convertStringToVector4(_ str:String) -> SCVector4 {
        
        let comps = str.components(separatedBy: ", ")
        
        let x = CGFloat((comps[0] as NSString).doubleValue)
        let y = CGFloat((comps[1] as NSString).doubleValue)
        let z = CGFloat((comps[2] as NSString).doubleValue)
        let w = CGFloat((comps[3] as NSString).doubleValue)
        
        return SCVector4(values: (x, y, z, w))
    }//convert string to vector 3
    
}// Converting Strings
