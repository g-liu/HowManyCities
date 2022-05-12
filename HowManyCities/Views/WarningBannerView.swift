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
  
  private var state: CityLimitWarning {
    didSet {
      guard state != oldValue else { return }
      UIView.animate {
        switch self.state {
          case .none:
            self.isHidden = true
            self.backgroundColor = .clear
            self.label.text = nil
          case .warning(let remaining):
            self.isHidden = false
            self.backgroundColor = .systemYellow
            // TODO: Pluralization
            self.label.text = "Approaching save limit — \(remaining) cities left"
          case .unableToSave(let surplus):
            self.isHidden = false
            self.backgroundColor = .systemRed
            self.label.text = "Unable to save, exceeded limit by \(surplus) cities"
        }
      }
    }
  }
  
  override init(frame: CGRect) {
    state = .none
    super.init(frame: frame)
    
    isHidden = true
    addSubview(label)
    label.pin(to: safeAreaLayoutGuide, margins: .init(top: 0, left: 16, bottom: 8, right: 16))
    
    isUserInteractionEnabled = true
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showExplanation)))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setState(_ state: CityLimitWarning) {
    self.state = state
  }
  
  @objc private func showExplanation() {
    let alert = UIAlertController(title: "Explanation",
                                  message: "You cannot save a game with more than 7,500 cities. However, you can continue adding cities to your map; you just won't be able to save your results permanently and get a shareable link.", preferredStyle: .alert)
    alert.addAction(.init(title: "Ok", style: .cancel))
    
    parentViewController?.show(alert, sender: self)
  }
}
