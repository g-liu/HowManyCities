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
  case specificState(_ state: State)
  case specificCountryState(_ state: StateGroup, _ index: Int)
  
  var string: String {
    switch self {
      case .any:
        return ""
      case .every:
        return "all"
      case .specificState(let location):
        return location.name
      case .specificCountryState(let group, let index):
        guard !group.states.isEmpty else {
          fatalError("Groups cannot be empty")
        }
        
        guard 0 <= index && index < group.states.count else {
          fatalError("Group index out of range")
        }
        
        return "\(group.states[index]), \(group.normalizedCountryName)"
    }
  }
  
  var menuName: String {
    switch self {
      case .any:
        return "Any country"
      case .every:
        return "Every country"
      case .specificState(let location):
        if let flag = location.flag {
          return "\(flag) \(location.name)"
        } else {
          return location.name
        }
      case .specificCountryState(let group, let index):
        let childState = group.states[index]
        // Unfortunately, can't use recursion here
        // There are locations in the world with same names as countries
        // e.g. Georgia (U.S. state) vs Georgia (country)
        // And we don't want to be mistakenly assigning country flags to non-countries with the same name
//          return GuessMode.specific(childState).menuName
        
        return childState.name
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
        
      case .specificState(let location):
        return shortName(for: location)
        
      case .specificCountryState(let group, let index):
        let childState = group.states[index]
        let groupAsState = State(name: group.group)
        let string = NSMutableAttributedString(attributedString: shortName(for: groupAsState))
        string.append(.init(string: "/", attributes: shortNameAttributes))
        string.append(.init(string: Global.STATE_ABBREVIATIONS[childState.name] ?? "", attributes: shortNameAttributes))
        
        return string
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
