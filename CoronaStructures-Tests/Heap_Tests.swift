//
//  Heap_Tests.swift
//  CoronaStructures
//
//  Created by Cooper Knaak on 8/15/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//

import Foundation
import XCTest
import CoronaStructures

class Heap_Tests: XCTestCase {
    
    var heap = Heap<Int>(comparator: { $0 < $1 })
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    ///Tests that the Heap is initialized with no elements.
    func testInitialization() {
        XCTAssert(heap.count == 0)
        XCTAssert(heap.isEmpty)
        XCTAssert(heap.peek() == nil)
    }
    
    ///Tests that the push method successfully adds an element
    ///to the heap.
    func testPush() {
        heap.push(value: 0)
        XCTAssert(heap.count == 1)
        XCTAssert(!heap.isEmpty)
        XCTAssert(heap.peek() == 0)
    }
    
    ///Tests that the push method successfully adds multiple
    ///elements to the heap in the correct order.
    func testPushTwice() {
        heap.push(value: 0)
        heap.push(value: 1)
        XCTAssert(heap.count == 2)
        XCTAssert(heap.peek() == 0)
    }
    
    ///Tests that the push method successfully adds multiple
    ///elements to the heap in a non-sorted order.
    func testPushTwiceOutOfOrder() {
        heap.push(value: 1)
        heap.push(value: 0)
        XCTAssert(heap.count == 2)
        XCTAssert(heap.peek() == 0)
    }
    
    ///Tests that the pop method successfully returns the first
    ///element in the heap when the heap has a single element.
    func testPopOnce() {
        heap.push(value: 1)
        XCTAssert(heap.pop() == 1)
        XCTAssert(heap.count == 0)
        XCTAssert(heap.isEmpty)
    }
    
    ///Tests that the pop method successfully returns the first
    ///element in the heap when the heap has multiple elements.
    func testPopTwice() {
        heap.push(value: 0)
        heap.push(value: 1)
        XCTAssert(heap.pop() == 0)
        XCTAssert(heap.pop() == 1)
    }
    
    ///Tests that the successive calls to the pop method return
    ///the previously pushed elements in the order defined by
    ///the heap's comparator. The elements are pushed in the
    ///same order they should be retrieved in.
    func testRetrieveInOrder() {
        heap.push(value: 0)
        heap.push(value: 1)
        heap.push(value: 2)
        heap.push(value: 3)
        heap.push(value: 4)
        heap.push(value: 5)
        XCTAssert(heap.pop() == 0)
        XCTAssert(heap.pop() == 1)
        XCTAssert(heap.pop() == 2)
        XCTAssert(heap.pop() == 3)
        XCTAssert(heap.pop() == 4)
        XCTAssert(heap.pop() == 5)
    }
    
    ///Tests that the successive calls to the pop method return
    ///the previously pushed elements in the order defined by
    ///the heap's comparator. The elements are pushed in the
    ///reverse order they should be retrieved in.
    func testRetrieveReversed() {
        heap.push(value: 5)
        heap.push(value: 4)
        heap.push(value: 3)
        heap.push(value: 2)
        heap.push(value: 1)
        heap.push(value: 0)
        XCTAssert(heap.pop() == 0)
        XCTAssert(heap.pop() == 1)
        XCTAssert(heap.pop() == 2)
        XCTAssert(heap.pop() == 3)
        XCTAssert(heap.pop() == 4)
        XCTAssert(heap.pop() == 5)
    }
    
    ///Tests that the successive calls to the pop method return
    ///the previously pushed elements in the order defined by
    ///the heap's comparator. The elements are pushed in a
    ///random order.
    func testRetrieveRandom() {
        heap.push(value: 2)
        heap.push(value: 4)
        heap.push(value: 5)
        heap.push(value: 1)
        heap.push(value: 3)
        heap.push(value: 0)
        XCTAssert(heap.pop() == 0)
        XCTAssert(heap.pop() == 1)
        XCTAssert(heap.pop() == 2)
        XCTAssert(heap.pop() == 3)
        XCTAssert(heap.pop() == 4)
        XCTAssert(heap.pop() == 5)
    }

    ///Tests that when iterating over the heap the elements are
    ///accessed in the order determined by the heap's comparator
    ///and that the heap is not consumed by iteration.
    func testIterator() {
        let elements = [2, 4, 5, 1, 3, 0]
        for element in elements {
            heap.push(value: element)
        }
        
        let sortedElements = elements.sorted()
        for (i, element) in heap.enumerated() {
            XCTAssert(element == sortedElements[i])
        }
        XCTAssert(heap.count == 6)
    }
 
    ///Tests that the heap can be modified via subscript and
    ///the heap remains in the proper order. The changed value
    ///should be heapified up.
    func testSubscriptUp() {
        heap.push(value: 0)
        heap.push(value: 1)
        heap.push(value: 2)
        heap.push(value: 3)
        heap[2] = -1
        XCTAssert(heap.pop() == -1)
        XCTAssert(heap.pop() == 0)
        XCTAssert(heap.pop() == 1)
        XCTAssert(heap.pop() == 3)
    }
    
    ///Tests that the heap can be modified via subscript and
    ///the heap remains in the proper order. The changed value
    ///should be heapified down.
    func testSubscriptDown() {
        heap.push(value: 0)
        heap.push(value: 1)
        heap.push(value: 2)
        heap.push(value: 3)
        heap[2] = 4
        XCTAssert(heap.pop() == 0)
        XCTAssert(heap.pop() == 1)
        XCTAssert(heap.pop() == 3)
        XCTAssert(heap.pop() == 4)
    }
    
    ///Tests that the heap can be modified via subscript and
    ///the heap remains in the proper order. The changed value
    ///should not be heapified.
    func testSubscriptInPlace() {
        heap.push(value: 0)
        heap.push(value: 1)
        heap.push(value: 3)
        heap.push(value: 4)
        heap[2] = 2
        XCTAssert(heap.pop() == 0)
        XCTAssert(heap.pop() == 1)
        XCTAssert(heap.pop() == 2)
        XCTAssert(heap.pop() == 4)
    }
    
    ///Tests that index(of:) returns the correct value. The
    ///elements have been added to the heap in order.
    func testIndexOfInOrder() {
        heap.push(value: 0)
        heap.push(value: 2)
        heap.push(value: 4)
        heap.push(value: 6)
        XCTAssert(heap.index(of: { $0 == 2 }) == 1)
    }
    
    ///Tests that index(of:) returns the correct value. The
    ///elements have been added to the heap in reverse order.
    func testIndexOfReversed() {
        heap.push(value: 6)
        heap.push(value: 4)
        heap.push(value: 2)
        heap.push(value: 0)
        XCTAssert(heap.index(of: { $0 == 2 }) == 1)
    }
}
