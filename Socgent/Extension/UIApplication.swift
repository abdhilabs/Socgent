//
//  UIApplication.swift
//  Socgent
//
//  Created by Abdhilabs on 11/01/26.
//

import UIKit

extension UIApplication {
  func openURLInBrowser(urlString: String, failedCompletion: (() -> Void)? = nil) {
    if let url = URL(string: urlString) {
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
      } else {
        failedCompletion?()
      }
    } else {
      failedCompletion?()
    }
  }
}
