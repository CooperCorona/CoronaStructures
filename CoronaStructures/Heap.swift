//
//  Heap.swift
//  CoronaStructures
//
//  Created by Cooper Knaak on 8/15/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//

import Foundation

public struct Heap<T> {
    
    private var heap:[T] = []
    public let comparator:(T, T) -> Bool
    
    public var count:Int { return self.heap.count }
    public var isEmpty:Bool { return self.heap.isEmpty }
    
    public init(comparator:@escaping (T, T) -> Bool) {
        self.comparator = comparator
    }
    
    public mutating func push(value:T) {
        self.heap.append(value)
        self.heapifyUp(at: self.count - 1)
    }
    
    public mutating func pop() -> T? {
        if self.count == 0 {
            return nil
        } else if self.count == 1 {
            return self.heap.removeFirst()
        }
        
        let returnValue = self.heap[0]
        self.heap[0] = self.heap[self.count - 1]
        self.heap.popLast()
        self.heapifyDown(at: 0)
        return returnValue
    }
    
    public func peek() -> T? {
        return self.heap.first
    }
    
    public subscript(index:Int) -> T {
        get {
            return self.heap[index]
        }
        set {
            let heapUp = self.comparator(newValue, self.heap[index])
            self.heap[index] = newValue
            if heapUp {
                self.heapifyUp(at: index)
            } else {
                self.heapifyDown(at: index)
            }
        }
    }
    
    public func index(of elementCallback: (T) -> Bool) -> Int? {
        for (i, element) in self.heap.enumerated() {
            if elementCallback(element) {
                return i
            }
        }
        return nil
    }
    
    private mutating func heapifyDown(at index:Int) {
        guard index < self.count else {
            return
        }
        let l = self.left(index: index)
        let r = self.right(index: index)
        switch (l, r) {
        case let (leftIndex?, rightIndex?):
            if self.comparator(self.heap[leftIndex], self.heap[rightIndex]) {
                if self.comparator(self.heap[leftIndex], self.heap[index]) {
                    swap(&self.heap[leftIndex], &self.heap[index])
                    heapifyDown(at: leftIndex)
                }
            } else {
                if self.comparator(self.heap[rightIndex], self.heap[index]) {
                    swap(&self.heap[rightIndex], &self.heap[index])
                    heapifyDown(at: rightIndex)
                }
            }
        case let (leftIndex?, nil):
            if self.comparator(self.heap[leftIndex], self.heap[index]) {
                swap(&self.heap[leftIndex], &self.heap[index])
                heapifyDown(at: leftIndex)
            }
        case let (nil, rightIndex?):
            if self.comparator(self.heap[rightIndex], self.heap[index]) {
                swap(&self.heap[rightIndex], &self.heap[index])
                heapifyDown(at: rightIndex)
            }
        case (nil, nil):
            //No children, cannot heapify down any further.
            break
        }
    }
    
    private mutating func heapifyUp(at index:Int) {
        guard let parentIndex = self.parent(index: index) else {
            return
        }
        if self.comparator(self.heap[index], self.heap[parentIndex]) {
            swap(&self.heap[index], &self.heap[parentIndex])
            self.heapifyUp(at: parentIndex)
        }
    }
    
    private func parent(index:Int) -> Int? {
        guard index > 0 else {
            return nil
        }
        return (index - 1) / 2
    }
    
    private func left(index:Int) -> Int? {
        let left = index * 2 + 1
        if left < self.count {
            return left
        } else {
            return nil
        }
    }
    
    private func right(index:Int) -> Int? {
        let right = index * 2 + 2
        if right < self.count {
            return right
        } else {
            return nil
        }
    }
    
}

extension Heap: IteratorProtocol {
    
    public mutating func next() -> T? {
        return self.pop()
    }
    
}

extension Heap: Sequence {
    
    public func makeIterator() -> Heap<T> {
        return self
    }
    
}
