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
open class SCCloudSingleton: NSObject {

    fileprivate var ubiquityToken:AnyObject? = nil
    fileprivate var iCloudEnabled = false
    open var iCloudIsEnabled:Bool { return self.iCloudEnabled }
    
    fileprivate var storeChangedBlocks:[String:() -> ()] = [:]
    fileprivate var identityChangedBlocks:[String:() -> ()] = [:]
    
    public override init() {
        
        self.ubiquityToken = FileManager.default.ubiquityIdentityToken
        self.iCloudEnabled = self.ubiquityToken !== nil
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SCCloudSingleton.ubiquityIdentityTokenChanged(_:)), name: NSNotification.Name.NSUbiquityIdentityDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SCCloudSingleton.keyValueStoreChanged(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)
    }//initialize
    
    open subscript(key:String) -> AnyObject? {
        get {
            return NSUbiquitousKeyValueStore.default().object(forKey: key) as AnyObject?
        }
        set {
            NSUbiquitousKeyValueStore.default().set(newValue, forKey: key)
        }
    }
    
    open func addStoreChangedBlock(_ block:CloudBlock) {
        self.storeChangedBlocks[block.identifier] = block.block
    }//add block
    
    open func addIdentityChangedBlock(_ block:CloudBlock) {
        self.identityChangedBlocks[block.identifier] = block.block
    }//add block
    
    open func removeStoreChangedBlock(_ identifier:String) {
        self.storeChangedBlocks[identifier] = nil
    }//remove block
    
    open func removeIdentityChangedBlock(_ identifier:String) {
        self.identityChangedBlocks[identifier] = nil
    }//remove block
    
    
    open func ubiquityIdentityTokenChanged(_ notification:Notification) {
        
        self.ubiquityToken = FileManager.default.ubiquityIdentityToken
        self.iCloudEnabled = self.ubiquityToken !== nil
        
        
        for (_, block) in self.identityChangedBlocks {
            block()
        }
        
    }//ubiquity identity token changed
    
    open func keyValueStoreChanged(_ notification:Notification) {
        
        for (_, block) in self.storeChangedBlocks {
            block()
        }
        
    }//ubiquitous key value store changed
    
    func synchronizeKeyValueStore() -> Bool {
        return NSUbiquitousKeyValueStore.default().synchronize()
    }
    
    
    func deleteKeyValueStore() {
        
        let kvStore = NSUbiquitousKeyValueStore.default()
        let dict = kvStore.dictionaryRepresentation
        
        for (key, _) in dict {
            kvStore.removeObject(forKey: key )
        }
        
    }//delete key value store
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
#endif
