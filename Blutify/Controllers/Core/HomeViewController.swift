//
//  ViewController.swift
//  Blutify
//
//  Created by Ricky Silitonga on 15/11/24.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
  let homeView: HomeView = HomeView()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    homeView.delegate = self

    setupView()
  }
  
  private func setupView() {
    view.addSubview(homeView)

    // setup constraint
    NSLayoutConstraint.activate([
        homeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        homeView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
        homeView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        homeView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  private func showAPIError(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}

extension HomeViewController: HomeViewDelegate {
  func didErrorWith(message: String) {
    showAPIError(message: message)
  }
}
