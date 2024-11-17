//
//  TabBarViewController.swift
//  Blutify
//
//  Created by Ricky Silitonga on 16/11/24.
//

import UIKit

// MARK: - For future use if the app need to add a tabbar
class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }
    
    private func setupTabBar() {
        let homeVC = HomeViewController()
        let searchVC = SearchViewController()
        
        homeVC.title = "Home"
        searchVC.title = "Search"
        
        homeVC.navigationItem.largeTitleDisplayMode = .always
        searchVC.navigationItem.largeTitleDisplayMode = .always
        
        let homeNavController = UINavigationController(rootViewController: homeVC)
        let searchNavController = UINavigationController(rootViewController: searchVC)
        
        homeNavController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        searchNavController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        homeNavController.navigationBar.prefersLargeTitles = true
        searchNavController.navigationBar.prefersLargeTitles = true
        
        
        setViewControllers([homeNavController, searchNavController], animated: true)
    }
}
