//
//  MapToast.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/21/22.
//

import Foundation
import UIKit

enum ToastType {
  case population
  case error
  case general
}

final class MapToast: UIView {
  private lazy var label: UILabel = {
    let label = UILabel().autolayoutEnabled
    
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 16)
    label.textColor = .white
    label.textAlignment = .center
    
    return label
  }()
  
  init(_ text: String, toastType: ToastType) {
    super.init(frame: .zero)
  
    label.text = text
    
    backgroundColor = { switch toastType {
    case .population:
      return .systemGreen
    case .error:
      return .systemRed
    case .general:
      return .systemGray3
    }}()
    addSubview(label)
    label.pin(to: self, margins: .init(horizontal: 8, vertical: 4))
    
    cornerRadius = 10
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
