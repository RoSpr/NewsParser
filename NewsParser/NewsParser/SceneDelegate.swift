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
            
        let tabBarController = createTabBarController()
        let newsNavigationController = createNewsNavigationController()
        let settingsNavigationController = createSettingsNavigationController()
        
        tabBarController.viewControllers = [newsNavigationController, settingsNavigationController]
        
        tabBarController.view.backgroundColor = .clear
        
        createInitialRSSSourcesIfNeeded()
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .willEnterForeground, object: nil)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .didEnterBackground, object: nil)
    }
    
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        let tabBar = tabBarController.tabBar
        
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterialLight)
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        return tabBarController
    }
    
    private func createNewsNavigationController() -> UINavigationController {
        let newsListViewController = NewsListViewController()
        newsListViewController.viewModel = NewsListViewControllerViewModelImpl()
        
        let newsNavigationController = UINavigationController(rootViewController: newsListViewController)
        newsNavigationController.tabBarItem = UITabBarItem(title: "News".localized(), image: UIImage(systemName: "newspaper"), tag: 0)
        
        newsNavigationController.configureAppeearance()
        
        return newsNavigationController
    }
    
    private func createSettingsNavigationController() -> UINavigationController {
        let settingsViewController = SettingsViewController()
        settingsViewController.viewModel = SettingsViewControllerViewModelImpl()
        
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        settingsNavigationController.tabBarItem = UITabBarItem(title: "Settings".localized(), image: UIImage(systemName: "gear"), tag: 1)
        
        settingsNavigationController.configureAppeearance()
        
        return settingsNavigationController
    }
    
    private func createInitialRSSSourcesIfNeeded() {
        if DatabaseManager.shared.fetch(NewsSource.self).count == 0 {
            let firstSource = NewsSource()
            firstSource.stringURL = "https://www.vedomosti.ru/rss/articles.xml"
            
            let secondSource = NewsSource()
            secondSource.stringURL = "https://news.ru/rss/"
            
            [firstSource, secondSource].forEach {
                DatabaseManager.shared.add($0)
            }
        }
    }
}
