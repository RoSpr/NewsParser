//
//  UINavigationController+Extensions.swift
//  NewsParser
//
//  Created by Rodion on 10.01.2025.
//

import Foundation
import UIKit

extension UINavigationController {
    func configureAppeearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .light)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
    }
}
