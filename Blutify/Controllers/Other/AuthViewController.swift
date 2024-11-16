//
//  AuthViewController.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import UIKit
import WebKit


class AuthViewController: UIViewController, WKNavigationDelegate {
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        return WKWebView(frame: .zero, configuration: configuration)
    }()
    
    public var completionHandler: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign In"
        view.backgroundColor = .systemBackground
        
        webView.navigationDelegate = self
        view.addSubview(webView)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
}
