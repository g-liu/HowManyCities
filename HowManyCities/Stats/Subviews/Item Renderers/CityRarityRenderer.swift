//
//  CityRarityRenderer.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/28/22.
//

import UIKit

final class CityRarityRenderer: ItemRenderer {
  func render(_ item: City) -> UIView? {
    let label = UILabel().autolayoutEnabled
    label.numberOfLines = 2
    label.attributedText = string(item)
    
    return label
  }
  
  func string(_ item: City) -> NSAttributedString {
    let rarity = item.percentageOfSessions ?? 0.0
    
    let mas = NSMutableAttributedString(string: "\(item.countryFlag)\(item.name)  ")
    mas.append(.init(string: percentage(from: rarity), attributes: [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                                                                       .foregroundColor: UIColor.systemGray]))
    
    return .init(attributedString: mas)
  }
  
  
  private func percentage(from double: Double) -> String {
    let value = round(double * 10000.0) / 100.0
    return "\(value)%"
  }
}
