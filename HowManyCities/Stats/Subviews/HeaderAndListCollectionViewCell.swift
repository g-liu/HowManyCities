//
//  HeaderAndListCollectionViewCell.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/27/22.
//

import UIKit

final class HeaderAndListCollectionViewCell: UICollectionViewCell {
  static let identifier = "HeaderAndListCollectionViewCell"
  
  private lazy var headerLabel: UILabel = {
    let label = UILabel().autolayoutEnabled
    label.numberOfLines = 2
    label.font = .boldSystemFont(ofSize: 24.0) // TODO: Support dynamic font type
    label.textAlignment = .left // TODO: Support RTL

    return label
  }()
  
  private lazy var numberedListView: NumberedListView = {
    let view = NumberedListView().autolayoutEnabled
    
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }

  private func setupView() {
    contentView.addSubview(headerLabel)
    contentView.addSubview(numberedListView)
    NSLayoutConstraint.activate([
      headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
      headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      numberedListView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
      numberedListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      numberedListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      numberedListView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])
  }

  func configure(header: String) {
    headerLabel.text = header
  }
}

final class NumberedListView: UIView {
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView().autolayoutEnabled
    stackView.axis = .vertical
    stackView.spacing = 4.0
    stackView.alignment = .leading
    
    return stackView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    addSubview(stackView)
    stackView.pin(to: self)
    
    // TODO: Test code remove PLEASE
    stackView.addArrangedSubviews((0..<10).map {
      let label = UILabel().autolayoutEnabled
      label.text = "\($0)"
      
      return label
    })
  }
}
