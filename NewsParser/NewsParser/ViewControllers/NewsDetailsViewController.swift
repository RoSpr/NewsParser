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
        imageView.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        
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
    
    private let downloadProgressView: CircularProgressBarView = {
        let progressView = CircularProgressBarView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addSubviews()
        setupConstraints()
        configure()
        
        setupNotificationObservers()
    }
    
    // Set value the same as it is in the other progress view
    private(set) lazy var downloadProgressHandler: ((Double) -> Void) = { [weak self] progress in
        guard let self = self else { return }
        DispatchQueue.main.async {
            self.downloadProgressView.setProgress(progress, animated: true)
        }
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        [newsTitleLabel, imageView, sourceTitleLabel, dateLabel, textView, downloadProgressView].forEach {
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
            
            downloadProgressView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            downloadProgressView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            downloadProgressView.widthAnchor.constraint(equalToConstant: 45),
            downloadProgressView.heightAnchor.constraint(equalTo: downloadProgressView.widthAnchor),
            
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
            
            if let image = viewModel.image {
                downloadProgressView.isHidden = true
                imageView.backgroundColor = .clear
                imageView.image = image
            } else {
                downloadProgressView.isHidden = false
            }
        }
        
        sourceTitleLabel.text = viewModel.sourceTitle
        dateLabel.text = viewModel.pubDate
        textView.text = viewModel.description
    }
    
    private func activateTopConstraint(hasImage: Bool) {
        topLabelsTopConstraintToImageView.isActive = hasImage
        topLabelsTopContraintToTop.isActive = !hasImage
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishImageDownload), name: .didFinishImageDownload, object: nil)
    }
    
    @objc private func didFinishImageDownload(_ notification: Notification) {
        guard let viewModel = viewModel,
              let realmId = viewModel.realmId,
              realmId == notification.userInfo?["realmId"] as? String else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.downloadProgressView.isHidden = true
            self.imageView.backgroundColor = .clear
            self.imageView.image = self.viewModel?.image
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

