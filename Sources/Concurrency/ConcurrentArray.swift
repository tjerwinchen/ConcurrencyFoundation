// ConcurrentArray.swift
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

import Foundation

/// Wraps the `Array` in a concurrent dictionary.
///
/// Example 1.
///
///     struct AwesomeStruct {
///       @ConcurrentArray
///       var array: [String] = []
///
///       func foo() {
///         $array.append(1)
///         $array.append(2)
///         $array = 3
///         $array.removeAll()
///       }
///     }
///
/// Example 2.
///
///     struct AwesomeStruct {
///       var array = ConcurrentArray<String>()
///
///       func foo() {
///         $array.append(1)
///         $array.append(2)
///         $array = 3
///         $array.removeAll()
///       }
///     }
@propertyWrapper
public final class ConcurrentArray<Element: Sendable>: Concurrent {
  // MARK: Lifecycle

  /// Initialize a concurrent array from a array
  public init(wrappedValue: [Element] = []) {
    self.unsafeValue = wrappedValue
  }

  // MARK: Public

  /// The wrapped value is the unsafe array
  public var wrappedValue: [Element] {
    unsafeValue
  }

  /// The projected concurrent array
  public var projectedValue: ConcurrentArray {
    self
  }

  /// Get the first element of the collection  in a thread-safe way.
  public var first: Element? {
    read(unsafeValue.first)
  }

  /// Get the last element of the collection  in a thread-safe way.
  public var last: Element? {
    read(unsafeValue.last)
  }

  /// A Boolean value indicating whether the collection is empty in a thread-safe way.
  public var isEmpty: Bool {
    read(unsafeValue.isEmpty)
  }

  /// The number of elements in the array in a thread-safe way.
  public var count: Int {
    read(unsafeValue.count)
  }

  /// Accesses the contiguous subrange of the collection's elements specified by a range expression in a thread-safe way.
  public subscript(index: Int) -> Element {
    _read {
      concurrentLock.readLock(); defer { concurrentLock.unlock() }
      yield unsafeValue[index]
    }
    _modify {
      concurrentLock.writeLock(); defer { concurrentLock.unlock() }
      yield &unsafeValue[index]
    }
  }

  /// Adds a new element at the end of the array in a thread-safe way.
  public func append(_ newElement: Element) {
    write(unsafeValue.append(newElement))
  }

  /// Adds a new element at the end of the array in a thread-safe way.
  public func append<S>(contentsOf newElements: S) where Element == S.Element, S: Sequence {
    write(unsafeValue.append(contentsOf: newElements))
  }

  // MARK: Internal

  let concurrentLock = ConcurrentLock()
  var unsafeValue: [Element]
}
