//
//  SCCloudSingleton.swift
//  Fields and Forces
//
//  Created by Cooper Knaak on 1/15/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
import UIKit
import CloudKit

public typealias CloudBlock = (identifier:String, block:() -> ())
public class SCCloudSingleton: NSObject {

    private var ubiquityToken:AnyObject? = nil
    private var iCloudEnabled = false
    public var iCloudIsEnabled:Bool { return self.iCloudEnabled }
    
    private var storeChangedBlocks:[String:() -> ()] = [:]
    private var identityChangedBlocks:[String:() -> ()] = [:]
    
    public override init() {
        
        self.ubiquityToken = NSFileManager.defaultManager().ubiquityIdentityToken
        self.iCloudEnabled = self.ubiquityToken !== nil
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SCCloudSingleton.ubiquityIdentityTokenChanged(_:)), name: NSUbiquityIdentityDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SCCloudSingleton.keyValueStoreChanged(_:)), name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: nil)
    }//initialize
    
    public subscript(key:String) -> AnyObject? {
        get {
            return NSUbiquitousKeyValueStore.defaultStore().objectForKey(key)
        }
        set {
            NSUbiquitousKeyValueStore.defaultStore().setObject(newValue, forKey: key)
        }
    }
    
    public func addStoreChangedBlock(block:CloudBlock) {
        self.storeChangedBlocks[block.identifier] = block.block
    }//add block
    
    public func addIdentityChangedBlock(block:CloudBlock) {
        self.identityChangedBlocks[block.identifier] = block.block
    }//add block
    
    public func removeStoreChangedBlock(identifier:String) {
        self.storeChangedBlocks[identifier] = nil
    }//remove block
    
    public func removeIdentityChangedBlock(identifier:String) {
        self.identityChangedBlocks[identifier] = nil
    }//remove block
    
    
    public func ubiquityIdentityTokenChanged(notification:NSNotification) {
        
        self.ubiquityToken = NSFileManager.defaultManager().ubiquityIdentityToken
        self.iCloudEnabled = self.ubiquityToken !== nil
        
        
        for (_, block) in self.identityChangedBlocks {
            block()
        }
        
    }//ubiquity identity token changed
    
    public func keyValueStoreChanged(notification:NSNotification) {
        
        for (_, block) in self.storeChangedBlocks {
            block()
        }
        
    }//ubiquitous key value store changed
    
    func synchronizeKeyValueStore() -> Bool {
        return NSUbiquitousKeyValueStore.defaultStore().synchronize()
    }
    
    
    func deleteKeyValueStore() {
        
        let kvStore = NSUbiquitousKeyValueStore.defaultStore()
        let dict = kvStore.dictionaryRepresentation
        
        for (key, value) in dict {
            kvStore.removeObjectForKey(key as! String)
        }
        
    }//delete key value store
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
#endif