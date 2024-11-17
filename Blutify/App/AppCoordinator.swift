//
//  AppCoordinator.swift
//  Blutify
//
//  Created by Ricky Silitonga on 17/11/24.
//

import Foundation
import UIKit

class AppCoordinator {
  private let window: UIWindow

  init(window: UIWindow) {
    self.window = window
  }

  func start() {
    authenticateUser()
  }

  private func authenticateUser() {
    BFRequest.shared.authenticate { [weak self] isSuccess in
      guard let self = self else { return }
      DispatchQueue.main.async {
        if isSuccess {
          print("Authenticated successfully!")
          self.showHomeScreen()
        } else {
          print("Failed to authenticate.")
          self.showWelcomeScreen()
        }
      }
    }
  }

  private func showHomeScreen() {
    let homeVC = HomeViewController()
    window.rootViewController = homeVC
    window.makeKeyAndVisible()
  }

  private func showWelcomeScreen() {
    let welcomeVC = WelcomeViewController()
    let navigationController = UINavigationController(rootViewController: welcomeVC)
    navigationController.navigationBar.prefersLargeTitles = true
    welcomeVC.navigationItem.largeTitleDisplayMode = .always
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
  }
}
