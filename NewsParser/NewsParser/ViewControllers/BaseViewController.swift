//
//  BaseViewController.swift
//  NewsParser
//
//  Created by Rodion on 23.12.2024.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    private let blurHeight = 50
    
    private let blurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.backgroundColor = .white.withAlphaComponent(0.7)
        
        let blurEffect = UIBlurEffect(style: .light)
        blurView.effect = blurEffect
        
        return blurView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBlurredTopBar()
        
        view.backgroundColor = .systemGray
    }
    
    private func setupBlurredTopBar() {
        view.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
