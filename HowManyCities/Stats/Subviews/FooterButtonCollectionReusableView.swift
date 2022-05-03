//
//  FooterButtonCollectionReusableView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit

protocol ToggleShowAllDelegate: AnyObject {
  func didToggle(_ showUpTo: Int)
}

final class FooterButtonCollectionReusableView: UICollectionReusableView {
  private lazy var button: UIButton = {
    let button = UIButton(configuration: .borderless()).autolayoutEnabled
    button.titleLabel?.textAlignment = .center
    
    button.setTitle("Show all", for: .normal) // TODO: Make configurable
    
    button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    
    return button
  }()
  
  weak var delegate: ToggleShowAllDelegate?
  
  private var showUpTo = 10 // TODO: Don't store state here, rely on your delegate??
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    addSubview(button)
    button.pin(to: safeAreaLayoutGuide)
  }
  
  @objc private func didTapButton() {
    if showUpTo == 10 {
      showUpTo = Int.max
      button.setTitle("Show less", for: .normal)
    } else {
      showUpTo = 10
      button.setTitle("Show all", for: .normal)
    }
    delegate?.didToggle(showUpTo)
  }
}
