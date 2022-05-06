//
//  GuessMode.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/23/22.
//

import Foundation
import UIKit

enum GuessMode {
  private var shortNameAttributes: [NSAttributedString.Key: Any] {
    [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
     .baselineOffset: (UIFont.systemFontSize - UIFont.smallSystemFontSize) / 2.0]
  }
  
  case any
  case every
  // Precondition: state.states is either nil, empty, or contains exactly 1 item
  case specific(_ state: State) // TODO: As State can be hierarchical, must differentiate between top level and lower level states especially in the derived variables
  
  var string: String {
    switch self {
      case .any:
        return ""
      case .every:
        return "all"
      case .specific(let location):
        // recursive case
        if let childState = location.states?.first {
          return GuessMode.specific(childState).string + ", " + location.normalizedCountryName
        }
        
        // base case
        return location.name
    }
  }
  
  var menuName: String {
    switch self {
      case .any:
        return "Any country"
      case .every:
        return "Every country"
      case .specific(let location):
        // recursive case
        if let childState = location.states?.first {
          // Unfortunately, can't use recursion here
          // There are locations in the world with same names as countries
          // e.g. Georgia (U.S. state) vs Georgia (country)
          // And we don't want to be mistakenly assigning country flags to non-countries with the same name
//          return GuessMode.specific(childState).menuName
          
          return childState.name
        }
        
        // base case
        if let flag = location.flag {
          return "\(flag) \(location.name)"
        } else {
          return location.name
        }
    }
  }
  
  var dropdownName: NSAttributedString {
    
    switch self {
      case .any:
        return NSAttributedString(string: "🌎")
        
      case .every:
        let countryCodeString = NSAttributedString(string: " ALL", attributes: shortNameAttributes)
        let ms = NSMutableAttributedString(string: "🌎")
        ms.append(countryCodeString)
        return .init(attributedString: ms)
        
      case .specific(let location):
        // recursive case
        if let childState = location.states?.first {
          let string = NSMutableAttributedString(attributedString: shortName(for: location))
          string.append(.init(string: "/", attributes: shortNameAttributes))
          // Can't use recursion here for the same reason as `menuName` :(
//          string.append(GuessMode.specific(childState).dropdownName)
          
          string.append(.init(string: Global.STATE_ABBREVIATIONS[childState.name] ?? "", attributes: shortNameAttributes))
          
          return string
        }
        
        // base case
        return shortName(for: location)
    }
  }
  
  private func shortName(for location: State) -> NSAttributedString {
    let countryCode = location.locale ?? Global.STATE_ABBREVIATIONS[location.name] ?? location.name
    
    let countryCodeString = NSAttributedString(string: "\(countryCode)", attributes: shortNameAttributes)
  
    if let flag = location.flag {
      let ms = NSMutableAttributedString(string: "\(flag) ")
      ms.append(countryCodeString)
      return .init(attributedString: ms)
    } else {
      return countryCodeString
    }
  }
}

extension GuessMode: Equatable { }
