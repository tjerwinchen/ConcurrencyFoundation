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
///       var dictionary = ConcurrentDictionary()
///
///       func foo() {
///         dictionary["key"] = "value"
///         dictionary.removeAll()
///       }
///     }
@propertyWrapper
public final class ConcurrentDictionary<Key: Hashable, Value> {
  // MARK: Lifecycle

  /// Initialize a concurrent dictionary from a dictionary
  public init(wrappedValue: [Key: Value] = [:]) {
    self.unsafeDictionary = wrappedValue
  }

  // MARK: Public

  /// The wrapped value is the unsafe dictionary
  public var wrappedValue: [Key: Value] {
    unsafeDictionary
  }

  /// The projected concurrent dictionary
  public var projectedValue: ConcurrentDictionary {
    self
  }

  /// The first element of the collection.
  public var first: (key: Key, value: Value)? {
    concurrentLock.readLock(); defer { concurrentLock.unlock() }
    return unsafeDictionary.first
  }

  /// The position of the first element in a nonempty dictionary.
  public var startIndex: Dictionary<Key, Value>.Index {
    concurrentLock.readLock(); defer { concurrentLock.unlock() }
    return unsafeDictionary.startIndex
  }

  /// The dictionary’s “past the end” position—that is, the position one greater than the last valid subscript argument.
  public var endIndex: Dictionary<Key, Value>.Index {
    concurrentLock.readLock(); defer { concurrentLock.unlock() }
    return unsafeDictionary.endIndex
  }

  /// The number of key-value pairs in the dictionary.
  public var count: Int {
    concurrentLock.readLock(); defer { concurrentLock.unlock() }
    return unsafeDictionary.count
  }

  /// A Boolean value that indicates whether the dictionary is empty.
  public var isEmpty: Bool {
    concurrentLock.readLock(); defer { concurrentLock.unlock() }
    return unsafeDictionary.isEmpty
  }

  /// Accesses the value associated with the given key for reading and writing.
  ///
  /// This *key-based* subscript returns the value for the given key if the key
  /// is found in the dictionary, or `nil` if the key is not found.
  ///
  /// - Parameter key: The key to find in the dictionary.
  /// - Returns: The value associated with `key` if `key` is in the dictionary;
  ///   otherwise, `nil`.
  public subscript(key: Key) -> Value? {
    _read {
      concurrentLock.readLock(); defer { concurrentLock.unlock() }
      yield unsafeDictionary[key]
    }
    _modify {
      concurrentLock.writeLock(); defer { concurrentLock.unlock() }
      yield &unsafeDictionary[key]
    }
  }

  /// Updates the value stored in the dictionary for the given key, or adds a
  /// new key-value pair if the key does not exist.
  ///
  /// - Parameters:
  ///   - value: The new value to add to the dictionary.
  ///   - key: The key to associate with `value`. If `key` already exists in
  ///     the dictionary, `value` replaces the existing associated value. If
  ///     `key` isn't already a key of the dictionary, the `(key, value)` pair
  ///     is added.
  /// - Returns: The value that was replaced, or `nil` if a new key-value pair
  ///   was added.
  @discardableResult
  public func updateValue(_ value: Value, forKey key: Key) -> Value? {
    concurrentLock.writeLock(); defer { concurrentLock.unlock() }
    return unsafeDictionary.updateValue(value, forKey: key)
  }

  /// Removes all key-value pairs from the dictionary.
  ///
  /// Calling this method invalidates all indices with respect to the
  /// dictionary.
  ///
  /// - Parameter keepCapacity: Whether the dictionary should keep its
  ///   underlying buffer. If you pass `true`, the operation preserves the
  ///   buffer capacity that the collection has, otherwise the underlying
  ///   buffer is released.  The default is `false`.
  public func removeAll(keepingCapacity keepCapacity: Bool = false) {
    concurrentLock.writeLock(); defer { concurrentLock.unlock() }
    unsafeDictionary.removeAll(keepingCapacity: keepCapacity)
  }

  // MARK: Private

  private var concurrentLock = ConcurrentLock()
  private var unsafeDictionary: [Key: Value]
}
