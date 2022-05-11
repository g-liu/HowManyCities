//
//  FooterTextCollectionReusableView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/4/22.
//

import UIKit

final class FooterTextCollectionReusableView: UICollectionReusableView {
  private lazy var label: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.caption1).autolayoutEnabled
    label.numberOfLines = 2
    label.textAlignment = .center
    
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
    addSubview(label)
    label.pin(to: safeAreaLayoutGuide)
  }
  
  func configure(text: String) {
    label.text = text
  }
}
