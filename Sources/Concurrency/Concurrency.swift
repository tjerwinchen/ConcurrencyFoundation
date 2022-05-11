// Concurrency.swift
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

// MARK: - Concurrency

/// A concurrent object to read values concurrently and block when writing.
///
/// Example:
///
///     @Concurrent
///     var values: [Int] = []
///
///     // update values
///     $values.updateValue {
///       $0.append(12)
///     }
///
///     // get values
///     $values.readValue {
///       safelyDealWithValue($0)
///     }
///
@propertyWrapper
public final class Concurrency<Value: Sendable>: Concurrent {
  // MARK: Lifecycle

  /// Creates a concurrency to wrap value that wraps the given instance.
  ///
  /// - Parameter wrappedValue: A  value to wrap.
  public init(wrappedValue: Value) {
    self.unsafeValue = wrappedValue
  }

  // MARK: Public

  /// The wrapped value is the unsafe value
  public var wrappedValue: Value {
    get {
      unsafeValue
    }
    set {
      unsafeValue = newValue
    }
  }

  /// The projected concurrent value
  public var projectedValue: Concurrency {
    self
  }

  /// Value in a thread-safe way
  public var safeValue: Value {
    read(unsafeValue)
  }

  /// Reading value in a thread-safe way and provide a post-action block when the value is fetched
  ///
  /// Example:
  ///
  ///     @Concurrent
  ///     var values: [Int] = []
  ///
  ///     $values.readValue {
  ///       safelyDealWithValue($0)
  ///     }
  @discardableResult
  public func readValue(action: (Value) -> Value) -> Value {
    read(action(unsafeValue))
  }

  /// Updating value in a thread-safe way and provide a post-action block to modify the value
  ///
  /// Example:
  ///
  ///     @Concurrent
  ///     var values: [Int] = []
  ///
  ///     $values.updateValue {
  ///       $0.append(12)
  ///     }
  @discardableResult
  public func updateValue(action: (inout Value) -> Value) -> Value {
    write(action(&unsafeValue))
  }

  // MARK: Internal

  let concurrentLock = ConcurrentLock()

  var unsafeValue: Value
}
