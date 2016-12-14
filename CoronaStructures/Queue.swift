//
//  Queue.swift
//  CoronaStructures
//
//  Created by Cooper Knaak on 10/23/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Foundation

///Linked-list style node to keep track of the queue.
fileprivate class QueueNode<T> {
    let object:T
    var next:QueueNode<T>? = nil
    
    init(object:T) {
        self.object = object
    }
}

/**
 Defines a first-in, first-out structure.
 */
public struct Queue<T>: CustomStringConvertible, ExpressibleByArrayLiteral {
    
    public typealias Element = T
    
    ///The node at the front of the queue
    ///(the next to be removed).
    private var head:QueueNode<T>? = nil
    ///The node at the end of the queue
    ///(the last to be removed).
    private var tail:QueueNode<T>? = nil
    ///The number of nodes in the queue.
    public var count = 0
    
    public var description:String {
        var desc = "]"
        var node = self.head
        var first = true
        while let currentNode = node {
            if first {
                desc = "\(currentNode.object)\(desc)"
                first = false
            } else {
                desc = "\(currentNode.object) -> \(desc)"
            }
            node = node?.next
        }
        desc = "[\(desc)"
        return desc
    }
    
    public init() {
        
    }
    
    public init<U: Sequence>(iterable:U) where U.Iterator.Element == T {
        for element in iterable.reversed() {
            self.enqueue(element)
        }
    }
    
    public init(arrayLiteral elements: Element...) {
        for element in elements.reversed() {
            self.enqueue(element)
        }
    }
    
    /**
     Adds an object to the end of the queue.
     - parameter object: The object to be enqueued.
     */
    public mutating func enqueue(_ object:T) {
        let node = QueueNode(object: object)
        if self.count == 0 {
            self.head = node
            self.tail = node
        } else {
            self.tail?.next = node
            self.tail = node
        }
        self.count += 1
    }
    
    /**
     Pops the object from the front of the queue.
     - returns: The object that was popped, or nil if the queue was empty.
     */
    public mutating func dequeue() -> T? {
        guard let object = self.head?.object else {
            return nil
        }
        self.head = self.head?.next
        if self.count == 1 {
            self.tail = nil
        }
        self.count -= 1
        return object
    }
    
    /**
     Accesses the element at the front of the queue without removing it.
     - returns: The front element of the queue, or nil if the queue is empty.
     */
    public func peek() -> T? {
        return self.head?.object
    }
    
}
