//
//  NewsTableViewCell.swift
//  NewsParser
//
//  Created by Rodion on 23.12.2024.
//

import Foundation
import UIKit

final class NewsTableViewCell: UITableViewCell {
    static let identifier: String = "NewsTableViewCell"
    
    var viewModel: NewsCellViewModel? = nil {
        didSet {
            self.configure()
        }
    }
    
    private(set) lazy var downloadProgressHandler: ((Double) -> Void) = { [weak self] progress in
        guard let self = self else { return }
        DispatchQueue.main.async {
            self.downloadProgressView.setProgress(progress, animated: true)
        }
    }
    
    private(set) lazy var downloadCompletedHandler: ((UIImage) -> Void) = { [weak self] image in
        guard let self = self else { return }
        DispatchQueue.main.async {
            self.downloadProgressView.isHidden = true
            self.newsImageView.image = image
        }
    }
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let downloadProgressView: CircularProgressBarView = {
        let progressView = CircularProgressBarView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        
        return progressView
    }()
    
    private let newsHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkText
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textAlignment = .left
        
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        return label
    }()
    
    private let isReadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .systemGray
        
        return imageView
    }()
    
    private let newsSourceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textAlignment = .left
        
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textAlignment = .right
        
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        return label
    }()
    
    private lazy var newsHeaderLeftToCellConstraint: NSLayoutConstraint = newsHeaderLabel.leftAnchor.constraint(equalTo: isReadImageView.rightAnchor, constant: 12)
    private lazy var newsHeaderLeftToImageViewConstraint: NSLayoutConstraint = newsHeaderLabel.leftAnchor.constraint(equalTo: newsImageView.rightAnchor, constant: 12)
    
    convenience init(viewModel: NewsCellViewModel) {
        self.init(style: .default, reuseIdentifier: NewsTableViewCell.identifier)
        self.viewModel = viewModel
        commonInit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Methods
    private func commonInit() {
        accessoryType = .disclosureIndicator
        backgroundColor = .white
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        [isReadImageView, newsImageView, downloadProgressView, newsHeaderLabel, newsSourceLabel, dateLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            isReadImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12),
            isReadImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            isReadImageView.heightAnchor.constraint(equalToConstant: 16),
            isReadImageView.widthAnchor.constraint(equalToConstant: 16),
            
            newsImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            newsImageView.leftAnchor.constraint(equalTo: isReadImageView.rightAnchor, constant: 12),
            newsImageView.heightAnchor.constraint(equalToConstant: 50),
            newsImageView.widthAnchor.constraint(equalTo: newsImageView.heightAnchor),
            
            downloadProgressView.centerXAnchor.constraint(equalTo: newsImageView.centerXAnchor),
            downloadProgressView.centerYAnchor.constraint(equalTo: newsImageView.centerYAnchor),
            downloadProgressView.widthAnchor.constraint(equalToConstant: 20),
            downloadProgressView.heightAnchor.constraint(equalTo: downloadProgressView.widthAnchor),
            
            newsHeaderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            newsHeaderLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12),
            
            newsSourceLabel.leftAnchor.constraint(equalTo: newsHeaderLabel.leftAnchor),
            newsSourceLabel.topAnchor.constraint(equalTo: newsHeaderLabel.bottomAnchor, constant: 4),
            newsSourceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            dateLabel.leftAnchor.constraint(equalTo: newsSourceLabel.rightAnchor, constant: 4),
            dateLabel.centerYAnchor.constraint(equalTo: newsSourceLabel.centerYAnchor),
            dateLabel.rightAnchor.constraint(equalTo: newsHeaderLabel.rightAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 21),
            dateLabel.widthAnchor.constraint(equalToConstant: 110),
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        if let image = viewModel.image {
            newsImageView.isHidden = false
            newsImageView.image = image
            downloadProgressView.isHidden = true
        } else if viewModel.hasImage && viewModel.image == nil {
            downloadProgressView.isHidden = false
        }
        
        setupLabelsLeftConstraints(hasImage: viewModel.hasImage)
        
        newsHeaderLabel.text = viewModel.newsHeader
        newsSourceLabel.text = viewModel.newsSource
        dateLabel.text = viewModel.newsDate
        
        isReadImageView.tintColor = viewModel.isRead ? .systemGreen : .systemGray
    }
    
    private func setupLabelsLeftConstraints(hasImage: Bool) {
        newsHeaderLeftToImageViewConstraint.isActive = hasImage
        newsHeaderLeftToCellConstraint.isActive = !hasImage
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
        newsImageView.image = nil
        newsImageView.isHidden = true
        downloadProgressView.setProgress(0, animated: false)
        downloadProgressView.isHidden = true
        newsHeaderLabel.text = nil
        newsSourceLabel.text = nil
        dateLabel.text = nil
        isReadImageView.tintColor = .systemGray
        setupLabelsLeftConstraints(hasImage: false)
    }
}
