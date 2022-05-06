//
//  StateCityCountRenderer.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/6/22.
//

import Foundation
import UIKit

final class StateCityCountRenderer: ItemRenderer {
  func string(_ item: (String, [City])) -> NSAttributedString {
    let stateName = item.0
    let cities = item.1
    
    let state = State(name: stateName)
    let mas = NSMutableAttributedString(string: "\(stateName)  ")
    if let flag = state.flag {
      mas.insert(.init(string: "\(flag) "), at: 0)
    }
    // TODO: Proper pluralization
    let pluralizedString = cities.count > 1 ? "cities" : "city"
    mas.append(.init(string: "\(cities.count) \(pluralizedString)", attributes: [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                                                                 .foregroundColor: UIColor.systemGray]))
    return mas
  }
  
  typealias ItemType = (String, [City])
  
  func render(_ item: (String, [City])) -> UIView? {
    nil
  }
}
