//
//  CollectionViewHeaderReusableView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/28/22.
//

import UIKit

protocol SegmentChangeDelegate: AnyObject {
  func didChange(segmentIndex: Int)
}

final class CollectionViewHeaderReusableView: UICollectionReusableView {
  override var reuseIdentifier: String? { "CollectionViewHeaderReusableView" }
  var text: String? {
    get { label.text }
    set { label.text = newValue }
  }
  
  weak var segmentChangeDelegate: SegmentChangeDelegate? = nil
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView().autolayoutEnabled
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.spacing = 8.0
    
    return stackView
  }()
  
  private lazy var label: UILabel = {
    let label = UILabel().autolayoutEnabled
    label.font = .boldSystemFont(ofSize: 24.0)
    return label
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
    stackView.addArrangedSubview(label)
    stackView.addArrangedSubview(control)
    
    addSubview(stackView)
    stackView.pin(to: safeAreaLayoutGuide)
//    NSLayoutConstraint.activate([
//      label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
//      label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
//      label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
//      label.bottomAnchor.constraint(equalTo: control.topAnchor, constant: -8),
////      control.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
//      control.leadingAnchor.constraint(equalTo: label.leadingAnchor),
//      control.trailingAnchor.constraint(equalTo: label.trailingAnchor),
//      control.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
//    ])
  }
  
  func configure(selectedSegmentIndex: Int, segmentTitles: [String]?) {
    guard let segmentTitles = segmentTitles,
          !segmentTitles.isEmpty else {
      control.isHidden = true
      return
    }

    control.isHidden = false
    control.segmentTitles = segmentTitles
    
    control.selectedSegmentIndex = selectedSegmentIndex
  }
  
  @objc private func didChangeSegmentIndex() {
    let index = control.selectedSegmentIndex
    segmentChangeDelegate?.didChange(segmentIndex: index)
  }
}
