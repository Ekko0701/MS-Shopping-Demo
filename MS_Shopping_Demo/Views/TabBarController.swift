//
//  TabBarController.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
}

//MARK: - View lifecycle
extension TabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
}

//MARK: - Configuration methods
extension TabBarController {
    private func configureTabBar() {
        self.delegate = self
        self.selectedIndex = 0
        
        tabBar.backgroundColor = .white
        tabBar.tintColor = .systemRed
        tabBar.isTranslucent = false
        
        tabBar.layer.addBorder(width: 0.3, radius: nil)
        
        let homeViewController = HomeViewController()
        let zzimViewController = ZzimViewController()
        
        homeViewController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        zzimViewController.tabBarItem = UITabBarItem(title: "좋아요", image: UIImage(systemName: "heart"), selectedImage: UIImage(systemName: "heart.fill"))
        
        viewControllers = [
            homeViewController,
            zzimViewController
        ]
        
    }
}
