//
//  UniversalSaverBase.swift
//  Fields and Forces
//
//  Created by Cooper Knaak on 12/30/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import Foundation

public class UniversalSaverBase: NSObject {
    
    public let fileName:String
    public let fileExtension:String
    public let fileDirectory:String?
    
    public var path:String { return UniversalSaverBase.pathForFile(self.fileName, fileExtension:self.fileExtension, directory:self.fileDirectory) }
    
    public init(file:String, fileExtension:String, directory:String?) {
        
        self.fileName = file
        self.fileExtension = fileExtension
        self.fileDirectory = directory
        
        if let directory = self.fileDirectory {
            UniversalSaverBase.createDirectoryAtPath(directory)
        }
        
        super.init()
        
    }//initialize
    
    
    public func save() -> Bool {
        
        let path = self.path
        
        let mData = NSMutableData()
        let archive = NSKeyedArchiver(forWritingWithMutableData: mData)
        
        self.saveWithArchiver(archive)
        
        archive.finishEncoding()
        return mData.writeToFile(path, atomically: true)
    }//save
    
    public func load() -> Bool {
        
        let path = self.path
        let data = NSData(contentsOfFile: path)
        
        if let validData = data {
            
            let unarchive = NSKeyedUnarchiver(forReadingWithData: validData)
            
            self.loadWithArchiver(unarchive)
            
            unarchive.finishDecoding()
            
            return true
        } else {
            return false
        }
        
    }//load
    
    public func saveWithArchiver(archive:NSKeyedArchiver) {
        
    }//save with NSKeyedArchiver
    
    public func loadWithArchiver(unarchive:NSKeyedUnarchiver) {
        
    }//load with NSKeyedUnarchiver
    
    // MARK: - Class Methods
    
    public class func pathForFile(file:String, fileExtension:String, directory:String? = nil) -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectoryPath = paths[0] as NSString
        var filePath = documentDirectoryPath
        
        if let validDirectory = directory {
            filePath = filePath.stringByAppendingPathComponent(validDirectory)
        }
        
        filePath = filePath.stringByAppendingPathComponent(file)
        filePath = filePath.stringByAppendingPathExtension(fileExtension)!
        
        return filePath as String
    }//get path in documents directory
    
    //Checks both documents directory and main bundle
    public class func fileExistsAtPath(file:String, fileExtension:String, directory:String? = nil) -> Bool {
        
        let documentsPath = UniversalSaverBase.pathForFile(file, fileExtension: fileExtension, directory: directory)
        if (NSFileManager.defaultManager().fileExistsAtPath(documentsPath)) {
            return true
        } else {
            return NSBundle.mainBundle().pathForResource(file, ofType: fileExtension) != nil
        }
        
    }//check if file exists in documents directory or in main bundle
    
    public class func pathForFileInDocumentsOrBundle(file:String, fileExtension:String, directory:String? = nil) -> String? {
        
        let documentsPath = UniversalSaverBase.pathForFile(file, fileExtension: fileExtension, directory: directory)
        
        if (NSFileManager.defaultManager().fileExistsAtPath(documentsPath)) {
            return documentsPath
        } else {
            return NSBundle.mainBundle().pathForResource(file, ofType: fileExtension)
        }
        
    }//get path in documents directory, or main bundle
    
    public class func createDirectoryAtPath(path:String) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectoryPath = paths[0] as NSString
        
        var filePath = documentDirectoryPath
        filePath = filePath.stringByAppendingPathComponent(path)
        
        if (!NSFileManager.defaultManager().fileExistsAtPath(filePath as String)) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(filePath as String, withIntermediateDirectories: false, attributes: nil)
            } catch _ {
            }
        }//folder needs to be created
        
    }//create directory at path
    
    public class func contentsOfDirectory(directory:String, removeExtensions:Bool = true) -> [NSURL] {

        do {
            var url = try NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false)
            url = url.URLByAppendingPathComponent(directory)
            
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            
            if removeExtensions {
                return contents.flatMap() { $0.URLByDeletingPathExtension }
            }
            
            return contents
            /*
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(totalDirectory)

            if removeExtensions {
                return contents.flatMap() { NSURL(string: $0)?.URLByDeletingPathExtension }
            } else {
                return contents.flatMap() { NSURL(string: $0) }
            }
            */
        } catch {
            return []
        }
        
    }
    
}
