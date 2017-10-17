//
//  DefaultDictionary.swift
//  CoronaStructures
//
//  Created by Cooper Knaak on 10/17/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//

import Foundation

///Represents a Dictionary with default values. If a user attempts to access
///a value that is not currently in the dictionary, a value is created,
///associated with a given key, and then returned. Thus, the dictionary
///does not return optional values, because a value will always exist.
public struct DefaultDictionary<Key: Hashable, Value>: CustomStringConvertible {
    
    ///The default value to be used when trying to access a key
    ///that does not exist in the dictionary.
    public let defaultValue:() -> Value
    
    ///The underlying dictionary storing key-value pairs.
    fileprivate var internalDictionary:[Key:Value] = [:]
    
    public var description: String { return "\(self.internalDictionary)" }
    
    ///Initializes a DefaultDictionary with a given block.
    ///- parameter defaultValue: A function that returns
    ///the default value used when trying to access a
    ///nonexistent key.
    public init(defaultValue:@escaping () -> Value) {
        self.defaultValue = defaultValue
    }
    
    ///Initializes a DefaultDictionary with a given block and values.
    ///- parameter dictionary: The key-value pairs to initialize the internal dictionary.
    ///- parameter defaultValue: A function that returns
    ///the default value used when trying to access a
    ///nonexistent key.
    public init(dictionary:[Key:Value], defaultValue:@escaping () -> Value) {
        self.defaultValue = defaultValue
        self.internalDictionary = dictionary
    }
    
    ///Initializes a DefaultDictionary with a given block and values.
    ///- parameter uniqueKeysWithValues: An array of key-value pairs to
    ///the internal dictionary. It is assumed the keys (the first element
    ///in the tuple) are unique.
    ///- parameter defaultValue: A function that returns
    ///the default value used when trying to access a
    ///nonexistent key.
    public init(uniqueKeysWithValues:[(Key, Value)], defaultValue:@escaping () -> Value) {
        self.defaultValue = defaultValue
        self.internalDictionary = [Key:Value](uniqueKeysWithValues: uniqueKeysWithValues)
    }
    
    ///Accesses the value of the underlying dictionary. If users attempt
    ///to get a value that does not exist, the default value is added
    ///to the dictionary and returned.
    ///- parameter key: The key.
    ///- parameter newValue: The value to associated with the key.
    public subscript(key:Key) -> Value {
        mutating get {
            if let value = self.internalDictionary[key] {
                return value
            } else {
                self.internalDictionary[key] = self.defaultValue()
                //It's safe to force-unwrap because the value was
                //set in the previous line.
                return self.internalDictionary[key]!
            }
        }
        set {
            self.internalDictionary[key] = newValue
        }
    }
    
}

///Conformance of the Collection protocol.
extension DefaultDictionary: Collection {
    
    public typealias Element = Dictionary<Key, Value>.Element
    public typealias Index = Dictionary<Key, Value>.Index
    
    public var startIndex:Index { return self.internalDictionary.startIndex }
    public var endIndex:Index { return self.internalDictionary.endIndex }
    
    public func index(after i: Index) -> Index {
        return self.internalDictionary.index(after: i)
    }
    
    public subscript(position: Dictionary<Key, Value>.Index) -> (key: Key, value: Value) {
        return self.internalDictionary[position]
    }
}
