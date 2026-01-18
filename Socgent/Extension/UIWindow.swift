//
//  UIWindow.swift
//  Socgent
//
//  Created by Abdhilabs on 17/01/26.
//

import UIKit

extension UIWindow {
  static var current: UIWindow? {
    let activeWindow = UIApplication
      .shared
      .connectedScenes
      .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
      .first { $0.isKeyWindow }
    return activeWindow
  }
  
  var currentViewController: UIViewController? {
    return getTopViewController(from: rootViewController)
  }
  
  private func getTopViewController(from viewController: UIViewController?) -> UIViewController? {
    if let navController = viewController as? UINavigationController {
      return getTopViewController(from: navController.visibleViewController)
    } else if let tabController = viewController as? UITabBarController,
              let selected = tabController.selectedViewController {
      return getTopViewController(from: selected)
    } else if let presented = viewController?.presentedViewController {
      return getTopViewController(from: presented)
    } else {
      return viewController
    }
  }
}
