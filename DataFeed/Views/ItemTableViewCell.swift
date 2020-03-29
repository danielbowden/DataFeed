//
//  ItemTableViewCell.swift
//  DataFeed
//
//  Created by Daniel Bowden on 29/3/20.
//  Copyright © 2020 Daniel Bowden. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    static let cellIdentifier = String(describing: self)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14.0)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = ItemViewModel.placeholderImage
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Constants.margin
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private struct Constants {
        static let margin = CGFloat(8.0)
        static let defaultLabelHeight = CGFloat(20.0)
    }
    
    private var viewModel: ItemViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.autoresizingMask = .flexibleHeight
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        contentView.addSubview(stackView)
        
        // lower the priority of the stackview's bottom constraint
        let bottomConstraint = stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.margin)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.defaultLabelHeight),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.margin),
            bottomConstraint,
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.margin),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.margin)
        ])
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: ItemViewModel) {
        self.viewModel = viewModel
    }
    
    private func updateUI() {
        titleLabel.text = viewModel?.title
        subtitleLabel.text = viewModel?.subtitle
    }
}
