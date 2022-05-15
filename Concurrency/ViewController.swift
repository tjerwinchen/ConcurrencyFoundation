// ViewController.swift
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

import Concurrency
import UIKit

class ViewController: UIViewController {
  @Concurrency var integers = [0, 1, 2]

  let label = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])

    view.backgroundColor = .systemBackground

    initData()
  }

  func initData() {
    DispatchQueue.concurrentPerform(iterations: 100) { idx in
      let values = $integers.updateValue(action: { values in
        values[idx % 3] = idx
        return values
      })

      if idx == 88 {
        DispatchQueue.main.async {
          self.title = "\(values) thread safe & value guaranteed"
        }
      }
    }

    DispatchQueue.concurrentPerform(iterations: 100) { idx in
      $integers.safeValue[idx % 3] = idx

      if idx == 88 {
        DispatchQueue.main.async {
          self.label.text = "\(self.$integers.safeValue) thread safe & value not guaranteed"
        }
      }
    }
  }
}
