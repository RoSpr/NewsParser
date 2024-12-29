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
            configure()
        }
    }
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let newsHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkText
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textAlignment = .left
        
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
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textAlignment = .right
        
        return label
    }()
    
    private lazy var newsHeaderLeftToCellConstraint: NSLayoutConstraint = newsHeaderLabel.leftAnchor.constraint(equalTo: isReadImageView.rightAnchor, constant: 12)
    private lazy var newsHeaderLeftToImageViewConstraint: NSLayoutConstraint = newsHeaderLabel.leftAnchor.constraint(equalTo: newsImageView.leftAnchor, constant: 12)
    
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
        [isReadImageView, newsImageView, newsHeaderLabel, newsSourceLabel, dateLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            isReadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            isReadImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            isReadImageView.heightAnchor.constraint(equalToConstant: 16),
            isReadImageView.widthAnchor.constraint(equalToConstant: 16),
            
            newsImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            newsImageView.leftAnchor.constraint(equalTo: isReadImageView.rightAnchor, constant: 12),
            newsImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            newsImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            newsImageView.widthAnchor.constraint(equalTo: newsImageView.heightAnchor),
            
            newsHeaderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            newsHeaderLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -48),
            
            newsSourceLabel.leftAnchor.constraint(equalTo: newsHeaderLabel.leftAnchor),
            newsSourceLabel.topAnchor.constraint(equalTo: newsHeaderLabel.bottomAnchor, constant: 4),
            newsSourceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
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
            newsImageView.image = image
        }
        
        setupLabelsLeftConstraints(hasImage: viewModel.image != nil)
        
        newsHeaderLabel.text = viewModel.newsHeader
        newsHeaderLabel.sizeToFit()
        
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
        
        newsImageView.image = nil
        newsImageView.isHidden = true
        newsHeaderLabel.text = nil
        isReadImageView.tintColor = .systemGray
    }
}
