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

  /// The first element of the collection.
  public var first: Element? {
    read(unsafeValue.first)
  }

  public var last: Element? {
    read(unsafeValue.last)
  }

  public var isEmpty: Bool {
    read(unsafeValue.isEmpty)
  }

  public var count: Int {
    read(unsafeValue.count)
  }

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

  public func append(_ newElement: Element) {
    write(unsafeValue.append(newElement))
  }

  public func append<S>(contentsOf newElements: S) where Element == S.Element, S: Sequence {
    write(unsafeValue.append(contentsOf: newElements))
  }

  // MARK: Internal

  let concurrentLock = ConcurrentLock()
  var unsafeValue: [Element]
}
