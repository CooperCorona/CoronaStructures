//
//  SCCloudSingleton+Convenience.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 11/10/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

#if os(iOS)
import Foundation

extension SCCloudSingleton {
    
    public func arrayForKey(key:String) -> [AnyObject]? {
        return NSUbiquitousKeyValueStore.defaultStore().arrayForKey(key)
    }
    
    public func setArray(array:[AnyObject]?, forKey key:String) {
        NSUbiquitousKeyValueStore.defaultStore().setArray(array, forKey: key)
    }
    
    public func boolArrayForKey(key:String) -> [BoolList.BoolType]? {
        if let array = self.arrayForKey(key) as? [String] {
            return self.boolsFromStrings(array)
        } else {
            return nil
        }
    }
    
    public func setBoolArray(array:[BoolList.BoolType], forKey key:String) {
        self.setArray(self.stringsFromBools(array), forKey: key)
    }
    
    public func stringsFromBools(boolValues:[BoolList.BoolType]) -> [String] {
        var strs:[String] = []
        for cur in boolValues {
            strs.append("\(cur)")
        }
        return strs
    }
    
    public func boolsFromStrings(stringValues:[String]) -> [BoolList.BoolType] {
        var bools:[BoolList.BoolType] = []
        for cur in stringValues {
            bools.append(BoolList.BoolType((cur as NSString).integerValue))
        }
        return bools
    }
    
}
#endif