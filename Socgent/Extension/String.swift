//
//  String.swift
//  Socgent
//
//  Created by Abdhilabs on 10/01/26.
//

import Foundation

extension String {
  var isNumber: Bool {
    allSatisfy { char in char.isNumber }
  }
}
