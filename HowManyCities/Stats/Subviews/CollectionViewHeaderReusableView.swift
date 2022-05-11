//
//  CollectionViewHeaderReusableView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/28/22.
//

import UIKit

final class CollectionViewHeaderReusableView: UICollectionReusableView {
  override var reuseIdentifier: String? { "CollectionViewHeaderReusableView" }
  var title: String? {
    get { label.text }
    set { label.text = newValue }
  }
  
  var subtitle: String? {
    get { subLabel.text }
    set { subLabel.text = newValue }
  }
  
  private var sortCb: (() -> Void)? = nil
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView().autolayoutEnabled
    stackView.axis = .horizontal
    stackView.spacing = 8.0
    stackView.alignment = .top

    return stackView
  }()
  
  private lazy var label: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.title1).autolayoutEnabled
    label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
    return label
  }()
  
  private lazy var subLabel: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.subheadline).autolayoutEnabled
    label.textColor = .systemGray
//    label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
    return label
  }()
  
  private lazy var sortButton: UIButton = {
    // TODO: DESIGN SUCKS UPDATE LATER
    var cfg = UIButton.Configuration.filled()
    cfg.title = "Sort"
    let button = UIButton(configuration: cfg).autolayoutEnabled
    button.isHidden = true
    button.addTarget(self, action: #selector(didTapSortButton), for: .touchUpInside)
    button.setContentHuggingPriority(.required, for: .horizontal)
    
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
    let titleStack = UIStackView().autolayoutEnabled
    titleStack.axis = .vertical
    titleStack.alignment = .leading
    titleStack.spacing = 8.0
//    titleStack.distribution = .fill
    titleStack.addArrangedSubviews([label, subLabel])
    
    stackView.addArrangedSubviews([titleStack, sortButton])
    
    addSubview(stackView)
    stackView.pin(to: safeAreaLayoutGuide, margins: .init(top: 8, left: 12, bottom: 8, right: 12))
  }
  
  func configure(sortCb: (() -> Void)? = nil) {
    self.sortCb = sortCb
    if let _ = sortCb {
      sortButton.isHidden = false
      sortButton.addTarget(self, action: #selector(didTapSortButton), for: .touchUpInside)
    } else {
      sortButton.isHidden = true
    }
  }
  
  @objc private func didTapSortButton() {
    sortCb?()
  }
}
