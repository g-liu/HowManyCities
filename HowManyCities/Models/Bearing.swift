//
//  Bearing.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/4/22.
//

import Foundation

enum Bearing: Double, CaseIterable {
  case n = 0.0
  case ne = 45.0
  case e = 90.0
  case se = 135.0
  case s = 180.0
  case sw = 225.0
  case w = 270.0
  case nw = 315.0
  
  init(rawValue: Double) {
    let normalizedValue: Double
    if rawValue < 0 {
      normalizedValue = (360.0 + (rawValue.truncatingRemainder(dividingBy: 360.0))).truncatingRemainder(dividingBy: 360.0)
    } else {
      normalizedValue = rawValue.truncatingRemainder(dividingBy: 360.0)
    }
    
    switch Int(floor((normalizedValue - 45.0/2.0) / 45.0)) {
      case -1, 7: self = .n
      case 0: self = .ne
      case 1: self = .e
      case 2: self = .se
      case 3: self = .s
      case 4: self = .sw
      case 5: self = .w
      case 6: self = .nw
      default: fatalError("WTF you tryna do my man?")
    }
  }
  
  // One of 8: ←↑→↓↖↗↘↙
  var asArrow: Character {
    switch self {
      case .n:
        return "↑\u{fe0e}"
      case .ne:
        return "↗\u{fe0e}"
      case .e:
        return "→\u{fe0e}"
      case .se:
        return "↘\u{fe0e}"
      case .s:
        return "↓\u{fe0e}"
      case .sw:
        return "↙\u{fe0e}"
      case .w:
        return "←\u{fe0e}"
      case .nw:
        return "↖\u{fe0e}"
    }
  }
  
  // Or bold variant: ⬉ ⬈ ⬊ ⬋⬆⬇⬅⮕
  // oof these don't render correctly on the default font
  var asBoldArrow: Character {
    switch self {
      case .n:
        return "⬆\u{fe0e}"
      case .ne:
        return "⬈\u{fe0e}"
      case .e:
        return "⮕\u{fe0e}"
      case .se:
        return "⬊\u{fe0e}"
      case .s:
        return "⬇\u{fe0e}"
      case .sw:
        return "⬋\u{fe0e}"
      case .w:
        return "⬅\u{fe0e}"
      case .nw:
        return "⬉\u{fe0e}"
    }
  }
}
