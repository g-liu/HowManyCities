//
//  WarningBannerView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/11/22.
//

import UIKit

final class WarningBannerView: UIView {
  private lazy var label: UILabel = {
    let label = UILabel().autolayoutEnabled
    label.numberOfLines = 2
    
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    isHidden = true
    addSubview(label)
    label.pin(to: safeAreaLayoutGuide, margins: .init(top: 0, left: 16, bottom: 8, right: 16))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setState(_ state: CityLimitWarning) {
    switch state {
      case .none:
        isHidden = true
        backgroundColor = .clear
        label.text = nil
      case .warning(let remaining):
        isHidden = false
        backgroundColor = .systemYellow
        label.text = "You're approaching the limit (\(remaining) cities left)"
      case .unableToSave(let surplus):
        isHidden = false
        backgroundColor = .systemRed
        label.text = "Unable to save now, you're over the limit by \(surplus) cities"
        
    }
  }
}
