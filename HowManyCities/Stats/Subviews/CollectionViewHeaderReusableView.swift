//
//  CollectionViewHeaderReusableView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/28/22.
//

import UIKit

protocol SectionChangeDelegate: AnyObject {
  func didChange(segmentIndex: Int)
}

final class CollectionViewHeaderReusableView: UICollectionReusableView {
  override var reuseIdentifier: String? { "CollectionViewHeaderReusableView" }
  var text: String? {
    get { label.text }
    set { label.text = newValue }
  }
  
  weak var delegate: SectionChangeDelegate? = nil
  private var sortCb: (() -> Void)? = nil
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView().autolayoutEnabled
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.spacing = 8.0
    
    return stackView
  }()
  
  private lazy var label: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.largeTitle).autolayoutEnabled
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
  
  private lazy var control: UISegmentedControl = {
    let control = UISegmentedControl().autolayoutEnabled
    control.isHidden = true
    control.addTarget(self, action: #selector(didChangeSegmentIndex), for: .valueChanged)
    
    return control
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
    
    stackView.addArrangedSubview(titleStack)
    stackView.addArrangedSubview(control)
    
    titleStack.pinSides(to: stackView)
    
    addSubview(stackView)
    stackView.pin(to: safeAreaLayoutGuide, margins: .init(top: 8, left: 12, bottom: 8, right: 12))
  }
  
  func configure(selectedSegmentIndex: Int = -1, segmentTitles: [String]? = nil, sortCb: (() -> Void)? = nil) {
    if let segmentTitles = segmentTitles,
       !segmentTitles.isEmpty {
      control.isHidden = false
      control.segmentTitles = segmentTitles
      
      control.selectedSegmentIndex = selectedSegmentIndex
    } else {
      control.isHidden = true
    }
    
    self.sortCb = sortCb
    if let _ = sortCb {
      sortButton.isHidden = false
      sortButton.addTarget(self, action: #selector(didTapSortButton), for: .touchUpInside)
    } else {
      sortButton.isHidden = true
    }
  }
  
  @objc private func didChangeSegmentIndex() {
    let index = control.selectedSegmentIndex
    delegate?.didChange(segmentIndex: index)
  }
  
  @objc private func didTapSortButton() {
    sortCb?()
  }
}
