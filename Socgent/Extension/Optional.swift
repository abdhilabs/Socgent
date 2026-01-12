//
//  Optional.swift
//  Socgent
//
//  Created by Abdhilabs on 10/01/26.
//

import Foundation

extension Optional {
  
  @inlinable
  @inline(__always)
  var isNil: Bool {
    return self == nil
  }
  
  @inlinable
  @inline(__always)
  var isNotNil: Bool {
    return self != nil
  }
}
