//
//  LoginViewController.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import UIKit

class WelcomeViewController: UIViewController {
  private let fetchAccessTokenButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = .white
    button.setTitle("Fetch Access Token", for: .normal)
    button.setTitleColor(.black, for: .normal)

    button.layer.cornerRadius = 25
    button.clipsToBounds = true

    return button
  }()

  private var loadingView: UIView?

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Blutify"
    view.backgroundColor = .systemBlue
    view.addSubview(fetchAccessTokenButton)
    fetchAccessTokenButton.addTarget(self, action: #selector(didTapFetch), for: .touchUpInside)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let buttonWidth: CGFloat = 240
    let buttonHeight: CGFloat = 50

    fetchAccessTokenButton.frame = CGRect(
      x: (view.frame.width - buttonWidth) / 2,
      y: (view.frame.height / 2) - buttonHeight,
      width: buttonWidth,
      height: buttonHeight
    )
  }

  private func showAPIError(message: String) {
    let alert = UIAlertController(title: "Error Authentication", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Refetch", style: .default, handler: { _ in
      self.didTapFetch()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  @objc func didTapFetch() {
    showLoadingView()
    BFRequest.shared.authenticate { [weak self] isSuccess in
      DispatchQueue.main.async {
        if isSuccess {
          print("Authenticated successfully!")

          // Transition to HomeViewController
          let homeViewController = HomeViewController()
          guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else { return }

          UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
              window.rootViewController = homeViewController
            },
            completion: nil
          )
        } else {
          self?.hideLoadingView()
          self?.showAPIError(message: "Failed to authenticate")
          self?.fetchAccessTokenButton.setTitle("Re-fetch Access Token", for: .normal)
        }
      }
    }
  }
}

// MARK: - Loading
extension WelcomeViewController {
  func showLoadingView() {
    guard self.loadingView == nil else { return }

    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.color = .white
    activityIndicator.startAnimating()
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(activityIndicator)

    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])

    self.loadingView = activityIndicator
  }

  func hideLoadingView() {
    loadingView?.removeFromSuperview()
    loadingView = nil
  }
}
