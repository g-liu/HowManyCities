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
    view.setContentHuggingPriority(.required, for: .vertical)
    
    return view
  }()
  
  private lazy var showMoreButton: UIButton = {
    let button = UIButton().autolayoutEnabled
    button.setTitle("Show more", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.buttonFontSize)
    button.addTarget(self, action: #selector(toggleItemsShown), for: .touchUpInside)
    
    return button
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
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(headerLabel)
    contentView.addSubview(numberedListView)
    contentView.addSubview(showMoreButton)
    NSLayoutConstraint.activate([
      headerLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8.0),
      headerLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8.0),
      headerLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -8.0),
      numberedListView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
      numberedListView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8.0),
      numberedListView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -8.0),
//      numberedListView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8.0),
      showMoreButton.topAnchor.constraint(equalTo: numberedListView.bottomAnchor, constant: 8.0),
      showMoreButton.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
      showMoreButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    contentView.pin(to: self.safeAreaLayoutGuide)
  }

  func configure<I: ItemRenderer>(header: String, items: [I.ItemType]?, renderer: I) {
    headerLabel.text = header
    numberedListView.configure(items: items, renderer: renderer)
    numberedListView.setShowing(5)
  }
  
  @objc private func toggleItemsShown() {
    numberedListView.showAll()
    showMoreButton.setTitle("Show less", for: .normal)
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
      numberLabel.setContentHuggingPriority(.required, for: .horizontal)
      numberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
      
      itemStack.addArrangedSubviews([
        numberLabel,
        view,
      ])
      
      stackView.addArrangedSubview(itemStack)
      NSLayoutConstraint.activate([
        itemStack.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
        itemStack.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      ])
      counter += 1
    }
  }
  
  func setShowing(_ count: Int) {
    let normalizedCount = max(min(stackView.arrangedSubviews.count, count), 1)
    stackView.arrangedSubviews.enumerated().forEach {
      $1.isHidden = ($0 > normalizedCount)
    }
  }
  
  func showAll() {
    stackView.arrangedSubviews.forEach { $0.isHidden = false }
  }
}
