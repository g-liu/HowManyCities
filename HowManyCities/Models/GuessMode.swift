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
  
  private var normalizedCountryNames: [String: String] {
    guard let url = Bundle.main.url(forResource: "NormalizedCountryNames", withExtension: "plist") else { return [:] }
    
    do {
      let data = try Data(contentsOf: url)
      let decoder = PropertyListDecoder()
      return try decoder.decode([String: String].self, from: data)
    } catch {
      print("Unable to read plist of normalized country names")
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
    let normalizedName = normalizedCountryName(fullCountryName)
    
    let identifier = NSLocale(localeIdentifier: "en_US")
    for localeCode in NSLocale.isoCountryCodes {
      let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
      if normalizedName.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current) == countryName?.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current) {
        return localeCode
      }
    }
    
    return ""
  }
  
  private func normalizedCountryName(_ string: String) -> String {
    normalizedCountryNames[string] ?? string
  }
}

extension GuessMode: Equatable { }
