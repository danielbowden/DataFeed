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
        imageView.layer.cornerRadius = Constants.margin / 2.0
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = Constants.margin
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let parentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillProportionally
        stackView.spacing = Constants.margin
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private struct Constants {
        static let margin = CGFloat(8.0)
        static let defaultLabelHeight = CGFloat(20.0)
        static let imageSize = CGSize(width: 60.0, height: 60.0)
    }
    
    private var viewModel: ItemViewModel? {
        didSet {
            updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Cell layout consists of a horizontal stackview containing both the image and another
        // vertical stackview containing the labels
        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(subtitleLabel)
        parentStackView.addArrangedSubview(iconImageView)
        parentStackView.addArrangedSubview(labelStackView)
        contentView.addSubview(parentStackView)
        contentView.autoresizingMask = .flexibleHeight
        
        // lower the priority of the stackview's bottom constraint
        let bottomConstraint = parentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.margin)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)
        
        // Pin the outer stackview to the cell's content view with a margin around the outside
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: Constants.defaultLabelHeight),
            parentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.margin),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize.width),
            parentStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.margin),
            parentStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.margin),
            bottomConstraint
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
