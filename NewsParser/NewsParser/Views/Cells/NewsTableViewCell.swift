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
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 1
        label.textAlignment = .left
        
        return label
    }()
    
    private let newsSourceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 1
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
    
    private lazy var newsSourceLeftToCellConstraint: NSLayoutConstraint = newsSourceLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8)
    private lazy var newsSourceLeftToImageViewConstraint: NSLayoutConstraint = newsSourceLabel.leftAnchor.constraint(equalTo: newsImageView.leftAnchor, constant: 12)
    
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
        [newsImageView, newsHeaderLabel, newsSourceLabel, isReadImageView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            newsImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            newsImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            newsImageView.heightAnchor.constraint(equalToConstant: 32),
            newsImageView.widthAnchor.constraint(equalToConstant: 32),
            
            newsSourceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            newsSourceLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -32),
            
            newsHeaderLabel.topAnchor.constraint(equalTo: newsSourceLabel.bottomAnchor, constant: 4),
            newsHeaderLabel.rightAnchor.constraint(equalTo: isReadImageView.leftAnchor, constant: -8),
            newsHeaderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            isReadImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -32),
            isReadImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            isReadImageView.heightAnchor.constraint(equalToConstant: 20),
            isReadImageView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        if let image = viewModel.image {
            newsImageView.image = image
        }
        
        setupLabelsLeftConstraints(hasImage: viewModel.image != nil)
        
        newsHeaderLabel.text = viewModel.newsHeader
        newsSourceLabel.text = viewModel.newsSource
        
        isReadImageView.tintColor = viewModel.isRead ? .systemGreen : .systemGray
    }
    
    private func setupLabelsLeftConstraints(hasImage: Bool) {
        newsSourceLeftToImageViewConstraint.isActive = hasImage
        newsSourceLeftToCellConstraint.isActive = !hasImage
        newsHeaderLabel.leftAnchor.constraint(equalTo: newsSourceLabel.leftAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        newsImageView.image = nil
        newsImageView.isHidden = true
        newsHeaderLabel.text = nil
        newsSourceLabel.text = nil
        isReadImageView.tintColor = .systemGray
    }
}
