//
//  CLLocationCoordinate2D+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/30/22.
//

import Foundation
import CoreLocation
import SwifterSwift

enum Bearing: Double, CaseIterable {
  case n = 0.0
//  case nne = 22.5
  case ne = 45.0
//  case ene = 67.5
  case e = 90.0
//  case ese = 112.5
  case se = 135.0
//  case sse = 157.5
  case s = 180.0
//  case ssw = 202.5
  case sw = 225.0
//  case wsw = 247.5
  case w = 270.0
//  case wnw = 292.5
  case nw = 315.0
//  case nnw = 337.5
  
  init(rawValue: Double) {
    let normalizedValue: Double
    if rawValue < 0 {
      normalizedValue = (360.0 + (rawValue.truncatingRemainder(dividingBy: 360.0))).truncatingRemainder(dividingBy: 360.0)
    } else {
      normalizedValue = rawValue.truncatingRemainder(dividingBy: 360.0)
    }
    
    switch Int(floor((normalizedValue - 45.0/2.0) / 45.0)) {
      // case 0: self = .n
      // case 1: self = .nne
      // case 2: self = .ne
      // case 3: self = .ene
      // case 4: self = .e
      // case 5: self = .ese
      // case 6: self = .se
      // case 7: self = .sse
      // case 8: self = .s
      // case 9: self = .ssw
      // case 10: self = .sw
      // case 11: self = .wsw
      // case 12: self = .w
      // case 13: self = .wnw
      // case 14: self = .nw
      // case 15: self = .nnw
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

extension CLLocationCoordinate2D {
  static let zero: Self = .init(latitude: 0, longitude: 0)
  
  static func +(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    .init(latitude: lhs.latitude + rhs.latitude, longitude: lhs.longitude + rhs.longitude)
  }
  
  static func /(lhs: CLLocationCoordinate2D, rhs: Int) -> CLLocationCoordinate2D {
    lhs / rhs.asDouble
  }
  
  static func /(lhs: CLLocationCoordinate2D, rhs: Double) -> CLLocationCoordinate2D {
    .init(latitude: lhs.latitude / rhs, longitude: lhs.longitude / rhs)
  }
}

extension CLLocationCoordinate2D {
  var asLocation: CLLocation {
    .init(self)
  }
  
  func bearing(to otherCoordinate: CLLocationCoordinate2D) -> Double {
    asLocation.bearing(to: otherCoordinate.asLocation)
  }
}

extension CLLocationCoordinate2D: Codable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(longitude)
    try container.encode(latitude)
  }
  
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    let longitude = try container.decode(CLLocationDegrees.self)
    let latitude = try container.decode(CLLocationDegrees.self)
    self.init(latitude: latitude, longitude: longitude)
  }
}

extension CLLocationCoordinate2D: Equatable {
  public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
}
