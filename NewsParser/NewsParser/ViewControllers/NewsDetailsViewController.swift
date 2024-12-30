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
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private var scrollContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
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
        imageView.contentMode = .scaleAspectFit
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
        textView.isScrollEnabled = false
        
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
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        [newsTitleLabel, imageView, sourceTitleLabel, dateLabel, textView].forEach {
            scrollContentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            scrollContentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollContentView.heightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor),
            
            newsTitleLabel.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor, constant: 16),
            newsTitleLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 12),
            newsTitleLabel.rightAnchor.constraint(equalTo: scrollContentView.rightAnchor, constant: -16),
            
            imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 48),
            imageView.topAnchor.constraint(equalTo: newsTitleLabel.bottomAnchor, constant: 6),
            imageView.rightAnchor.constraint(equalTo: scrollContentView.rightAnchor, constant: -48),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.8),
            
            sourceTitleLabel.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor, constant: 16),
            sourceTitleLabel.widthAnchor.constraint(equalTo: dateLabel.widthAnchor),
            
            dateLabel.leftAnchor.constraint(equalTo: sourceTitleLabel.rightAnchor, constant: 2),
            dateLabel.rightAnchor.constraint(equalTo: scrollContentView.rightAnchor, constant: -16),
            dateLabel.topAnchor.constraint(equalTo: sourceTitleLabel.topAnchor),
            
            textView.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor),
            textView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            textView.rightAnchor.constraint(equalTo: scrollContentView.rightAnchor),
            textView.bottomAnchor.constraint(lessThanOrEqualTo: scrollContentView.bottomAnchor)
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

