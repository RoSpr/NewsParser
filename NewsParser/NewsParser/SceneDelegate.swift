//
//  SceneDelegate.swift
//  NewsParser
//
//  Created by Rodion on 22.12.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        
        let tabBarController = UITabBarController()
        let tabBar = tabBarController.tabBar
        tabBar.unselectedItemTintColor = .systemGray3
        
        // Add blur to the tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .light)
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        
        let newsListViewController = NewsListViewController()
        newsListViewController.tabBarItem = UITabBarItem(title: "Новости", image: UIImage(systemName: "newspaper"), tag: 0)
        
        let settingsViewController = SettingsViewController()
        settingsViewController.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 1)
        
        tabBarController.viewControllers = [newsListViewController, settingsViewController]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}

