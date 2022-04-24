//
//  MapGuessViewModel.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation
import CoreLocation
import MapKit

protocol MapGuessDelegate: AnyObject {
  func didReceiveCities(_ cities: [City])
  func didReceiveError(_ error: CityGuessError)
  func didSaveResult(_ response: GameFinishResponse?)
  
  func didChangeGuessMode(_ mode: GuessMode)
}

final class MapGuessViewModel: NSObject {
  var delegate: MapGuessDelegate?
  
  private(set) var guessMode: GuessMode = .any
  var selectedRow: Int = 0 // TODO: BAD!!!!
  
  private var model: MapGuessModel = .init()
  
  var lastRegion: MKCoordinateRegion {
    get {
      model.lastRegion
    } set {
      model.lastRegion = newValue
    }
  }
  
  // MARK: statistics
  
  var numCitiesGuessed: Int { model.guessedCities.count }
  var populationGuessed: Int { model.guessedCities.reduce(0) { $0 + $1.population } }
  
  private var citiesGuessedSortedIncreasing: [City] {
    model.guessedCities.sorted { c1, c2 in
      if c1.population == c2.population {
        if c1.name == c2.name {
          return c1.fullTitle < c2.fullTitle
        }
        return c1.name < c2.name
      }
      return c1.population < c2.population
    }
  }
  
  var largestGuessed: [City] {
    citiesGuessedSortedIncreasing.suffix(10)
  }
  
  var smallestGuessed: [City] {
    citiesGuessedSortedIncreasing.prefix(10).asArray
  }
  
  var rarestGuessed: [City] {
    model.guessedCities.sorted { c1, c2 in
      (c1.percentageOfSessions ?? 0.0) < (c2.percentageOfSessions ?? 0.0)
    }.prefix(10).asArray
  }
  
  var percentageTotalPopulationGuessed: Double {
    guard let config = model.gameConfiguration else {
      return 0
    }
    return populationGuessed / config.totalPopulation.asDouble
  }
  
  override init() {
    super.init()
    let decoder = JSONDecoder()
    if let savedGameState = UserDefaults.standard.object(forKey: "gamestate") as? Data,
       let decodedModel = try? decoder.decode(MapGuessModel.self, from: savedGameState) {
      model = decodedModel
    } else {
      model = .init()
      retrieveConfiguration()
    }
  }
  
  private func retrieveConfiguration() {
    HMCRequestHandler.shared.retrieveConfiguration { [weak self] config in
      self?.model.gameConfiguration = config
    }
  }
  
  func saveGameState() {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(model) {
      UserDefaults.standard.set(encoded, forKey: "gamestate")
    }
  }
  
  func submitGuess(_ guess: String) {
    let formattedGuess: String
    if case .any = guessMode {
      formattedGuess = guess
    } else {
      formattedGuess = guess + ", \(guessMode.string)"
    }
    
    HMCRequestHandler.shared.submitGuess(formattedGuess) { [weak self] response in
      if let cities = response?.cities {
        if !cities.isEmpty {
          self?.model.usedMultiCityInput ||= (cities.count > 1)
          
          var newCities = [City]()
          cities.forEach { city in
            let result = self?.model.guessedCities.insert(city)
            if result?.inserted ?? false {
              newCities.append(city)
            }
          }
          
          if newCities.isEmpty {
            self?.delegate?.didReceiveError(.alreadyGuessed)
          } else {
            self?.delegate?.didReceiveCities(newCities)
          }
        } else {
          self?.delegate?.didReceiveError(.noneFound(guess))
        }
      } else {
        self?.delegate?.didReceiveError(.serverError)
      }
    }
  }
  
  var guessedCities: Set<City> {
    model.guessedCities
  }
  
  func resetState() {
    model.resetState()
  }
  
  func finishGame() {
    HMCRequestHandler.shared.finishGame(cities: Array(model.guessedCities), startTime: model.startTime, usedMultiCityInput: model.usedMultiCityInput) { [weak self] res in
      self?.delegate?.didSaveResult(res)
    }
  }
}

struct MapGuessModel: Codable {
  var guessedCities: Set<City> = .init()
  var gameConfiguration: GameConfiguration?
  var startTime: Date = .now
  var usedMultiCityInput: Bool = false
  var lastRegion: MKCoordinateRegion = .init(center: .zero, span: .full)
  
  mutating func resetState() {
    guessedCities = .init()
  }
}

enum CityGuessError: Error {
  case noneFound(_ cityName: String)
  case alreadyGuessed
  case emptyGuess
  case serverError
  
  var message: String {
    switch self {
      case .noneFound(let name):
        return "No city named \(name.capitalized) found!"
      case .alreadyGuessed:
        return "Already guessed!"
      case .emptyGuess:
        return "Please enter a city name"
      case .serverError:
        return "We're having technical issues, please try again"
    }
  }
}

extension MapGuessViewModel: GuessModeDelegate {
  func didChangeGuessMode(_ mode: GuessMode) {
    guessMode = mode
    delegate?.didChangeGuessMode(mode)
  }
}

//extension MapGuessViewModel: UIPickerViewDelegate, UIPickerViewDataSource {
//  func numberOfComponents(in pickerView: UIPickerView) -> Int {
//    1
//  }
//
//  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//    (model.gameConfiguration?.topLevelStates.count ?? 0) + 2
//  }
//
//  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//    if row == 0 { return "Any country" }
//    if row == 1 { return "Every country" }
//
//    guard let states = model.gameConfiguration?.topLevelStates else {
//      return nil
//    }
//
//    return states[row-2].name
//  }
//
//  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//    selectedRow = row
//
//    if row == 0 { guessMode = .any }
//    if row == 1 { guessMode = .every }
//
//    if row >= 2, let states = model.gameConfiguration?.topLevelStates {
//      guessMode = .specific(states[row-2])
//    }
//
//    delegate?.didChangeGuessMode(guessMode)
//  }
//
//}


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
//          string.append(shortName(for: childState.name))
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
      // TODO: apply this to all given states
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

extension GuessMode: Equatable {
//  static func == (lhs: GuessMode, rhs: GuessMode) -> Bool {
//    switch (lhs, rhs) {
//      case (.any, .any):
//        return true
//      case (.every, .every):
//        return true
//      case (.specific(let state1), .specific(let state2)):
//        return state1 == state2
//      default:
//        return false
//    }
//  }
}

extension MapGuessViewModel: StatesDataSource {
  var topLevelStates: [State] {
    model.gameConfiguration?.topLevelStates ?? []
  }
  
  var lowerDivisionStates: [State] {
    model.gameConfiguration?.lowerDivisionStates ?? []
  }
}
