//
//  HeaderAndListCollectionViewCell.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/27/22.
//

import UIKit

protocol ItemRenderer: AnyObject {
  associatedtype ItemType
  func render(_ item: ItemType) -> UIView?
}

final class HeaderAndListCollectionViewCell: UICollectionViewCell {
  static let identifier = "HeaderAndListCollectionViewCell"
  
  private lazy var headerLabel: UILabel = {
    let label = UILabel().autolayoutEnabled
    label.numberOfLines = 2
    label.font = .boldSystemFont(ofSize: 24.0) // TODO: Support dynamic font type
    label.textAlignment = .left // TODO: Support RTL
    label.setContentCompressionResistancePriority(.required, for: .vertical)

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
      headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
      headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0),
      numberedListView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
      numberedListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
      numberedListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0),
      numberedListView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -8.0),
    ])
  }

  func configure<I: ItemRenderer>(header: String, items: [I.ItemType]?, renderer: I) {
    headerLabel.text = header
    numberedListView.configure(items: items, renderer: renderer)
  }
}

final class NumberedListView: UIView {
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView().autolayoutEnabled
    stackView.axis = .vertical
    stackView.spacing = 8.0
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
  }
  
  func configure<I: ItemRenderer>(items: [I.ItemType]?, renderer: I) {
    // SwifterSwift in iOS 12 has a problem so I have to write this manually
    // can't just call stackView.removeArrangedSubviews()
    // Fucking thing SUCKS!
    // https://stackoverflow.com/a/52718219/1387572
    stackView.arrangedSubviews.forEach {
      stackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    
    var counter = 1
    items?.forEach { item in
      guard let view = renderer.render(item) else { return }
      
      let itemStack = UIStackView().autolayoutEnabled
      itemStack.distribution = .fill
      itemStack.alignment = .lastBaseline
      itemStack.spacing = 12.0
      itemStack.axis = .horizontal
      
      let numberLabel = UILabel().autolayoutEnabled
      numberLabel.numberOfLines = 1
      numberLabel.textAlignment = .left
      numberLabel.text = "\(counter)."
      numberLabel.font = numberLabel.font.withSize(UIFont.smallSystemFontSize)
      
      itemStack.addArrangedSubviews([
        numberLabel,
        view,
      ])
      
      stackView.addArrangedSubview(itemStack)
      counter += 1
    }
  }
}
