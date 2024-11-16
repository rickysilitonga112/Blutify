//
//  ViewController.swift
//  Blutify
//
//  Created by Ricky Silitonga on 15/11/24.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        print("Api key")
        print(AppPreference.shared.apiKey)
        
        print("Base Path")
        print(AppPreference.shared.baseUrl)
    }


}

