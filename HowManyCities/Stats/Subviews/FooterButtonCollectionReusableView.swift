//
//  FooterButtonCollectionReusableView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit

//protocol ToggleShowAllDelegate: AnyObject {
//  func didToggle(_ isShowingAll: Bool)
//}

final class FooterButtonCollectionReusableView: UICollectionReusableView {
  private lazy var button: UIButton = {
    let button = UIButton(configuration: .borderless()).autolayoutEnabled
    button.titleLabel?.textAlignment = .center
    button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    
    return button
  }()
  
//  weak var delegate: ToggleShowAllDelegate?
  private var tapCallback: ((Bool) -> Void)? = nil
  
  private var isShowingAll: Bool = false {
    didSet {
      if isShowingAll {
        button.setTitle("Show less", for: .normal)
      } else {
        button.setTitle("Show all", for: .normal)
      }
    }
  }
  
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
    button.pin(to: safeAreaLayoutGuide, margins: .init(top: 8, left: 12, bottom: 8, right: 12))
  }
  
  func configure(isShowingAll: Bool, tapCallback: ((Bool) -> Void)? = nil) {
    self.isShowingAll = isShowingAll
    self.tapCallback = tapCallback
  }
  
  @objc private func didTapButton() {
    isShowingAll = !isShowingAll
//    delegate?.didToggle(isShowingAll)
    tapCallback?(isShowingAll)
  }
}
