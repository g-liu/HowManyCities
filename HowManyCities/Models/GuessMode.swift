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
  
  private var stateAbbreviations: [String: String] {
    guard let url = Bundle.main.url(forResource: "StateAbbreviations", withExtension: "plist") else { return [:] }
    
    do {
      let data = try Data(contentsOf: url)
      let decoder = PropertyListDecoder()
      return try decoder.decode([String: String].self, from: data)
    } catch {
      print("Unable to read plist of state abbreviations")
      return [:]
    }
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
          return GuessMode.specific(childState).string + ", " + normalizedCountryName(location.name)
        }
        
        // base case
        return location.name
    }
  }
  
  var fullDisplayName: String {
    switch self {
      case .any:
        return "Any country"
      case .every:
        return "Every country"
      case .specific(let location):
        // recursive case
        if let childState = location.states?.first {
          return GuessMode.specific(childState).fullDisplayName
        }
        
        // base case
        let countryCode = locale(for: location.name)
        let flag = flag(for: countryCode)
        
        if flag.isEmpty {
          return location.name
        }
        return "\(flag) \(location.name)"
    }
  }
  
  var shortDisplayName: NSAttributedString {
    
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
          // in this case location.name could be something like "U.S. States" in which case we have to normalize it
          let normalizedTopLevelCountryName = normalizedCountryName(location.name)
          let string = NSMutableAttributedString(attributedString: shortName(for: normalizedTopLevelCountryName))
          string.append(.init(string: "/", attributes: shortNameAttributes))
          string.append(GuessMode.specific(childState).shortDisplayName)
          
          return string
        }
        
        // base case
        return shortName(for: location.name)
    }
  }
  
  private func shortName(for locationName: String) -> NSAttributedString {
    var countryCode = locale(for: locationName)
    let flag = flag(for: countryCode)
    
    if countryCode.isEmpty {
      // maybe it's a state we're dealing with
      countryCode = stateAbbreviations[locationName] ?? ""
    }
    
    let countryCodeString = NSAttributedString(string: "\(countryCode)", attributes: shortNameAttributes)
  
    if !flag.isEmpty {
      let ms = NSMutableAttributedString(string: "\(flag) ")
      ms.append(countryCodeString)
      return .init(attributedString: ms)
    } else {
      return countryCodeString
    }
  }
  
  private func flag(for countryCode: String) -> String {
    let base: UInt32 = 127397
    var s = ""
    for v in countryCode.unicodeScalars {
      s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
  }
  
  
  private func locale(for fullCountryName: String) -> String {
    // special cases
    if fullCountryName.lowercased() == "China".lowercased() {
      return "CN"
    } else if fullCountryName.lowercased() == "Democratic Republic of the Congo".lowercased() {
      return "CD"
    } else if fullCountryName.lowercased() == "Republic of the Congo".lowercased() {
      return "CG"
    } else if fullCountryName.lowercased() == "Federated States of Micronesia".lowercased() {
      return "FM"
    } else if fullCountryName.lowercased() == "Ivory Coast".lowercased() {
      return "CI"
    } else if fullCountryName.lowercased() == "Myanmar".lowercased() {
      return "MM"
    } else if fullCountryName.lowercased() == "Palestine".lowercased() {
      return "PS"
    } else if fullCountryName.lowercased() == "St. Vincent and the Grenadines".lowercased() {
      return "VC"
    } else if fullCountryName.lowercased() == "The Gambia".lowercased() {
      return "GM"
    }
    
    let locales = ""
    for localeCode in NSLocale.isoCountryCodes {
      let identifier = NSLocale(localeIdentifier: "en_US")
      let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
      if fullCountryName.lowercased() == countryName?.lowercased() ||
          fullCountryName.replacingOccurrences(of: " and ", with: " & ").lowercased() == countryName?.lowercased() {
        return localeCode
      }
    }
    return locales
  }
  
  private func normalizedCountryName(_ string: String) -> String {
    if string.starts(with: "Australian") {
      return "Australia"
    } else if string.starts(with: "Brazilian") {
      return "Brazil"
    } else if string.starts(with: "Canadian") {
      return "Canada"
    } else if string.starts(with: "Mexican") {
      return "Mexico"
    } else if string.starts(with: "U.S.") {
      return "United States"
    } else {
      return string
    }
  }
}

extension GuessMode: Equatable { }
