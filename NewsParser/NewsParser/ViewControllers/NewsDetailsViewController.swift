//
//  NewsDetailsViewController.swift
//  NewsParser
//
//  Created by Rodion on 22.12.2024.
//

import Foundation
import UIKit

final class NewsDetailsViewController: UIViewController {
    var viewModel: NewsDetailsViewControllerViewModel? = nil
    
    private lazy var topLabelsTopContraintToTop: NSLayoutConstraint = sourceTitleLabel.topAnchor.constraint(equalTo: newsTitleLabel.bottomAnchor, constant: 10)
    private lazy var topLabelsTopConstraintToImageView: NSLayoutConstraint = sourceTitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10)
    
    private var newsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .darkText
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        imageView.isHidden = true
        
        return imageView
    }()
    
    private var sourceTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray3
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray3
        label.textAlignment = .right
        
        return label
    }()
    
    private var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .darkText
        textView.isEditable = false
        textView.backgroundColor = .white
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addSubviews()
        setupConstraints()
        configure()
    }
    
    private func addSubviews() {
        [newsTitleLabel, imageView, sourceTitleLabel, dateLabel, textView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            newsTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            newsTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            newsTitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 48),
            imageView.topAnchor.constraint(equalTo: newsTitleLabel.bottomAnchor, constant: 6),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -48),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.8),
            
            sourceTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            sourceTitleLabel.widthAnchor.constraint(equalTo: dateLabel.widthAnchor),
            
            dateLabel.leftAnchor.constraint(equalTo: sourceTitleLabel.rightAnchor, constant: 2),
            dateLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            dateLabel.topAnchor.constraint(equalTo: sourceTitleLabel.topAnchor),
            
            textView.leftAnchor.constraint(equalTo: view.leftAnchor),
            textView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        activateTopConstraint(hasImage: viewModel.hasImage)

        navigationItem.largeTitleDisplayMode = .never
        
        newsTitleLabel.text = viewModel.title
        
        if viewModel.hasImage {
            imageView.isHidden = false
            imageView.image = viewModel.image
        }
        
        sourceTitleLabel.text = viewModel.sourceTitle
        dateLabel.text = viewModel.pubDate
        textView.text = viewModel.description
        
    }
    
    private func activateTopConstraint(hasImage: Bool) {
        topLabelsTopConstraintToImageView.isActive = hasImage
        topLabelsTopContraintToTop.isActive = !hasImage
    }
}

