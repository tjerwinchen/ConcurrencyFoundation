// ConcurrencyTests.swift
//
// Copyright (c) 2022 Codebase.Codes
// Created by Theo Chen on 2022.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

@testable import ConcurrencyFoundation
import XCTest

// MARK: - AwesomeClass

class AwesomeClass {
  var intValue = 0
  var boolValue = false
}

// MARK: - ConcurrencyTests

final class ConcurrencyTests: XCTestCase {
  func test_concurrency() throws {
    @Concurrency
    var numbers: [Int] = []

    @Concurrency
    var awesomeClass = AwesomeClass()

    let count = 100

    DispatchQueue.concurrentPerform(iterations: count) { idx in
      $numbers.updateValue { value in
        value.append(idx)
        return value
      }

      $numbers.readValue { value in
        XCTAssertNotNil(value.last)
        return value
      }

      $awesomeClass.updateValue { value in

        if value.boolValue {
          value.intValue += 1
        } else {
          value.intValue -= 1
        }
        value.boolValue = !value.boolValue
        return value
      }
    }
    XCTAssertEqual(numbers.count, count)
    XCTAssertEqual(awesomeClass.intValue, 0)
    XCTAssertEqual(awesomeClass.boolValue, false)
  }

  func test_array() throws {

    let expectation = XCTestExpectation()
    let count = 100
    let dispatchGroup = DispatchGroup()
    
    @ConcurrentArray
    var array: [[Int]] = (0 ..< count).compactMap {_ in
      []
    }

    for idx in 0 ..< count {
      dispatchGroup.enter()
      DispatchQueue.global().async {
        XCTAssertNotNil($array.first)
        XCTAssertGreaterThan($array.count, 0)
        $array[idx] = [idx, idx]
        XCTAssertEqual($array[idx], [idx, idx])
        dispatchGroup.leave()
      }
    }

    dispatchGroup.notify(queue: .main) {
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
    XCTAssertEqual(array.count, count)
  }

  func test_dictionary() throws {
    @ConcurrentDictionary
    var dict: [Int: [Int: Int]] = [:]

    let expectation = XCTestExpectation()
    let count = 100
    let dispatchGroup = DispatchGroup()

    for idx in 0 ..< count {
      dispatchGroup.enter()
      DispatchQueue.global().async {
        $dict[idx, default: [:]] = [idx: idx]
        XCTAssertNotNil($dict.first)
        XCTAssertGreaterThan($dict.count, 0)
        XCTAssertEqual($dict[idx], [idx: idx])
        dispatchGroup.leave()
      }
    }

    dispatchGroup.notify(queue: .main) {
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 10)
    XCTAssertEqual(dict.count, count)
  }
}
