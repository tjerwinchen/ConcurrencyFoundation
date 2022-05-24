// ConcurrentDictionary.swift
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

// MARK: - ConcurrentDictionary

/// Wraps the `Dictionary` in a concurrent dictionary.
///
/// Example 1.
///
///     struct AwesomeStruct {
///       @ConcurrentDictionary
///       var dictionary = [String: String]()
///
///       func foo() {
///         $dictionary["key"] = "value"
///         $dictionary.removeAll()
///       }
///     }
///
/// Example 2.
///
///     struct AwesomeStruct {
///       var dictionary = ConcurrentDictionary<String, String>()
///
///       func foo() {
///         dictionary["key"] = "value"
///         dictionary.removeAll()
///       }
///     }
@propertyWrapper
public final class ConcurrentDictionary<Key: Hashable, Value>: Concurrent where Key: Sendable, Value: Sendable {
  // MARK: Lifecycle

  /// Initialize a concurrent dictionary from a dictionary
  public init(wrappedValue: [Key: Value] = [:]) {
    self.unsafeValue = wrappedValue
  }

  // MARK: Public

  /// The wrapped value is the unsafe dictionary
  public var wrappedValue: [Key: Value] {
    unsafeValue
  }

  /// The projected concurrent dictionary
  public var projectedValue: ConcurrentDictionary {
    self
  }

  /// The first element of the collection.
  public var first: (key: Key, value: Value)? {
    read(unsafeValue.first)
  }

  /// The position of the first element in a nonempty dictionary.
  public var startIndex: Dictionary<Key, Value>.Index {
    read(unsafeValue.startIndex)
  }

  /// The dictionary’s “past the end” position—that is, the position one greater than the last valid subscript argument.
  public var endIndex: Dictionary<Key, Value>.Index {
    read(unsafeValue.endIndex)
  }

  /// The number of key-value pairs in the dictionary.
  public var count: Int {
    read(unsafeValue.count)
  }

  /// A Boolean value that indicates whether the dictionary is empty.
  public var isEmpty: Bool {
    read(unsafeValue.isEmpty)
  }

  /// Accesses the value associated with the given key for reading and writing in a thread safe way.
  public subscript(key: Key) -> Value? {
    _read {
      concurrentLock.readLock(); defer { concurrentLock.unlock() }
      yield unsafeValue[key]
    }
    _modify {
      concurrentLock.writeLock(); defer { concurrentLock.unlock() }
      yield &unsafeValue[key]
    }
  }

  /// Accesses the value associated with the given key for reading and writing  in a thread safe way.
  public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
    _read {
      concurrentLock.readLock(); defer { concurrentLock.unlock() }
      yield unsafeValue[key, default: defaultValue()]
    }
    _modify {
      concurrentLock.writeLock(); defer { concurrentLock.unlock() }
      yield &unsafeValue[key, default: defaultValue()]
    }
  }

  /// In a thread safe way, updates the value stored in the dictionary for the given key, or adds a
  /// new key-value pair if the key does not exist.
  @discardableResult
  public func updateValue(_ value: Value, forKey key: Key) -> Value? {
    write(unsafeValue.updateValue(value, forKey: key))
  }

  /// Removes all key-value pairs from the dictionary in a thread safe way.
  public func removeAll(keepingCapacity keepCapacity: Bool = false) {
    write(unsafeValue.removeAll(keepingCapacity: keepCapacity))
  }

  // MARK: Internal

  let concurrentLock = ConcurrentLock()
  var unsafeValue: [Key: Value]
}
