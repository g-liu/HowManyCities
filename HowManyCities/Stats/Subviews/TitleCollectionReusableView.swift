//
//  TitleCollectionReusableView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/28/22.
//

import UIKit

class TitleCollectionReusableView: UICollectionReusableView {
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
    label.pin(to: self)
  }
}
