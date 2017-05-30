//
//  WeightedRandomBag.swift
//  CoronaStructures
//
//  Created by Cooper Knaak on 5/29/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//

import Foundation

/**
 Defines a collection of elements with functionality to
 access random elements. Each element can be weighted
 so some elements are more likely than others. The weight
 specified is relative. You can use any scale as long as
 it is consistent with other elements' weighting.
 */
public struct WeightedRandomBag<T> {
    
    private struct Element {
        var weight:CGFloat
        var element:T
        
        func with(weight:CGFloat) -> Element{
            return Element(weight: weight, element: self.element)
        }
    }
    
    private var elements:[Element] = []
    private var totalWeight:CGFloat = 0.0
    public var count:Int { return self.elements.count }
    
    public init() {
        
    }
    
    public mutating func add(element:T, weight:CGFloat) {
        self.elements.append(Element(weight: weight, element: element))
        self.totalWeight += weight
    }
    
    public mutating func remove(elementsMatching: @escaping (T) -> Bool) {
        self.elements = self.elements.filter() { !elementsMatching($0.element) }
        self.totalWeight = self.elements.reduce(0.0) { $0 + $1.weight }
    }
    
    private func normalize(elements:[Element], totalWeight:CGFloat) -> [Element] {
        return elements.map() { $0.with(weight: $0.weight / totalWeight) } .sorted() { $0.weight > $1.weight }
    }
    
    private func normalize(elements:[Element]) -> [Element] {
        let totalWeight = elements.reduce(0.0) { $0 + $1.weight }
        return self.normalize(elements: elements, totalWeight: totalWeight)
    }
    
    public func randomElement() -> T? {
        guard self.elements.count > 0 else {
            return nil
        }
        /*
         *  We normalize all the weights, then sort them
         *  in DESCENDING order. We check if the generated
         *  random number is less than the LAST element's
         *  weight (so for an element with normalized weight
         *  0.75, obviously a uniform random number in [0, 1]
         *  will be less than 0.75 75% of the time. If not,
         *  remove the element from the list, renormalize
         *  it, and repeat.
         */
        var r = CGFloat.random()
        var normalized = self.normalize(elements: self.elements)
        var totalWeight = normalized.reduce(0.0) { $0 + $1.weight }
        var i = 0
        while i < normalized.count - 1 && normalized[i].weight < r {
            i += 1
            totalWeight = normalized[i..<normalized.count].reduce(0.0) { $0 + $1.weight }
            r = CGFloat.random() * totalWeight
        }
        return normalized[i].element
    }
    
}
