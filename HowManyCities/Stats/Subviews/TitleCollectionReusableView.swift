//
//  TitleCollectionReusableView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/28/22.
//

import UIKit

final class TitleCollectionReusableView: UICollectionReusableView {
  override var reuseIdentifier: String? { "TitleCollectionReusableView" }
  var text: String? {
    get { label.text }
    set { label.text = newValue }
  }
  
  private lazy var label: UILabel = {
    let label = UILabel().autolayoutEnabled
    label.font = .boldSystemFont(ofSize: 24.0)
    return label
  }()
  
  private lazy var control: UISegmentedControl = {
    let control = UISegmentedControl().autolayoutEnabled
    control.isHidden = true
    
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
    addSubview(label)
    addSubview(control)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      
      control.topAnchor.constraint(equalTo: label.bottomAnchor),
      control.leadingAnchor.constraint(equalTo: label.leadingAnchor),
      control.trailingAnchor.constraint(equalTo: label.trailingAnchor),
      control.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
    ])
  }
  
  func configure(segmentTitles: [String]?) {
    guard let segmentTitles = segmentTitles,
          !segmentTitles.isEmpty else {
      control.isHidden = true
      return
    }

    control.isHidden = false
    control.segmentTitles = segmentTitles
    control.selectedSegmentIndex = 0
  }
}
