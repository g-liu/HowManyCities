//
//  NumberedListCollectionViewCell.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit

final class NumberedListCollectionViewCell: UICollectionViewCell {
  private lazy var itemStack: UIStackView = {
    let stackView = UIStackView().autolayoutEnabled
    stackView.distribution = .fill
    stackView.alignment = .lastBaseline
    stackView.spacing = 12.0
    stackView.axis = .horizontal
    
    return stackView
  }()
  
  // TODO: Make this a separate cell and integrate with the existing collection view??
  private lazy var numberLabel: UILabel = {
    let label = UILabel().autolayoutEnabled
    label.numberOfLines = 1
    label.textAlignment = .left
    label.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
    label.setContentHuggingPriority(.required, for: .horizontal)
    label.setContentCompressionResistancePriority(.required, for: .horizontal)
    
    return label
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
    contentView.addSubview(itemStack)
    itemStack.pin(to: contentView.safeAreaLayoutGuide)
  }
  
  func configure<I: ItemRenderer>(order: Int, item: I.ItemType, renderer: I) {
    // SwifterSwift in iOS 12 has a problem so I have to write this manually
    // can't just call stackView.removeArrangedSubviews()
    // Fucking thing SUCKS!
    // https://stackoverflow.com/a/52718219/1387572
    itemStack.arrangedSubviews.forEach {
      itemStack.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    
    guard let view = renderer.render(item) else { return }
    
    numberLabel.text = "\(order)."
    
    itemStack.addArrangedSubviews([numberLabel, view])
  }
}
