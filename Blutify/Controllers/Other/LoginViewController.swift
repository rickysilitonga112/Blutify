//
//  LoginViewController.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import UIKit

class LoginViewController: UIViewController {
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In With Spotify", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Blutify"
        view.backgroundColor = .systemBlue
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signInButton.frame = CGRect(
            x: 24,
            y: view.height-50-view.safeAreaInsets.bottom,
            width: view.width - 40,
            height: 50
        )
    }
    
    @objc func didTapSignIn() {
        let authVC = AuthViewController()
        authVC.navigationItem.largeTitleDisplayMode = .never
        
        authVC.completionHandler = { [weak self] isSuccess in
            guard let self else { return }
            handleUserSignIn(isSuccess: isSuccess)
        }
        navigationController?.pushViewController(authVC, animated: true)
    }
    
    private func handleUserSignIn(isSuccess: Bool) {
         
    }
    
}
