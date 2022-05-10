//
//  CollectionViewHeaderReusableView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/28/22.
//

import UIKit

final class CollectionViewHeaderReusableView: UICollectionReusableView {
  override var reuseIdentifier: String? { "CollectionViewHeaderReusableView" }
  var text: String? {
    get { label.text }
    set { label.text = newValue }
  }
  
  private var sortCb: (() -> Void)? = nil
  
//  private lazy var stackView: UIStackView = {
//    let stackView = UIStackView().autolayoutEnabled
//    stackView.axis = .vertical
//    stackView.alignment = .leading
//    stackView.spacing = 8.0
//
//    return stackView
//  }()
  
  private lazy var label: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.title1).autolayoutEnabled
    label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
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
    titleStack.axis = .horizontal
    titleStack.alignment = .center
    titleStack.distribution = .fill
    titleStack.addArrangedSubviews([label, sortButton])
    
    addSubview(titleStack)
    titleStack.pin(to: safeAreaLayoutGuide, margins: .init(top: 8, left: 12, bottom: 8, right: 12))
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
