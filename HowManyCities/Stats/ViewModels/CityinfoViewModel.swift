//
//  CityinfoViewModel.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/11/22.
//

import Foundation
import UIKit
import MapKit

struct CityInfoViewModel {
  weak var statsProvider: GameStatisticsProvider?
  
  private let nearbyThreshold: Double = 500_000 // in meters
  
  let city: City
  
  /// A list of the nearest cities, where "near" must be less than the value defined in `nearbyThreshold`
  private let nearbyCities: [City]?

  /// The nearest city, regardless of `nearbyThreshold`
  private let nearestCity: City?
  
  var nearbyCityList: [NSAttributedString]? {
    nearbyCities?.map {
      // TODO: Make this a renderer???
      let distanceInKm = city.distance(to: $0) / 1000.0
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .decimal
      if distanceInKm > 0 {
        numberFormatter.maximumFractionDigits = Int(max(0, ceil(-log10(distanceInKm) + 1.0)))
      } else {
        numberFormatter.maximumFractionDigits = 0
      }
      let distanceInKmString = numberFormatter.string(from: distanceInKm as NSNumber) ?? String(distanceInKm)

      let bearing = city.bearing(to: $0)

      let cityTitle = comparativeName(for: $0)
      let mas = NSMutableAttributedString(string: "\(cityTitle)  ")
      mas.append(.init(string: "\(distanceInKmString)km \(bearing.asArrow)", attributes: [.foregroundColor: UIColor.systemGray]))
      
      return mas
    }
  }
  
  var nearestCityText: NSAttributedString? {
    guard let nearestCity = nearestCity else {
      return nil
    }

    let cityName = comparativeName(for: nearestCity)
    let distance = Int(round(city.distance(to: nearestCity) / 1000.0))
    let bearing = city.bearing(to: nearestCity)
    
    let mas = NSMutableAttributedString(string: "The closest city you guessed is ")
    mas.append(.init(string: cityName, attributes: [.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)]))
    mas.append(.init(", which is "))
    mas.append(.init(string: "\(distance.commaSeparated)km \(bearing.asArrow)", attributes: [.foregroundColor: UIColor.systemGray]))
    mas.append(.init(string: " away."))
    
    return mas
  }
  
  var nearbyCityAnnotations: [MKPointAnnotation]? {
    nearbyCities?.map {
      let annotation = $0.asAnnotation
      annotation.title = comparativeName(for: $0)
      annotation.subtitle = "pop: \($0.population.commaSeparated)"
      
      return annotation
    }
  }
  
  var nearestCityAnnotation: MKPointAnnotation? {
    guard let nearestCity = nearestCity else {
      return nil
    }

    
    let annotation = nearestCity.asAnnotation
    
    annotation.title = comparativeName(for: nearestCity)
    annotation.subtitle = "pop: \(nearestCity.population.commaSeparated)"
    
    return annotation
  }
  
  init(city: City, statsProvider: GameStatisticsProvider?) {
    self.city = city
    self.statsProvider = statsProvider
    
    self.nearbyCities = statsProvider?.guessedCities(near: city, threshold: nearbyThreshold, limit: 10)
    
    if let nearestCity = nearbyCities?.first {
      self.nearestCity = nearestCity
    } else {
      self.nearestCity = statsProvider?.nearestCity(to: city)
    }
  }
  
  private func comparativeName(for otherCity: City) -> String {
    if city.country != otherCity.country {
      return otherCity.fullTitle
    } else if city.state != otherCity.state {
      return otherCity.nameWithStateAbbr
    }
    return otherCity.name
  }
   
  // TODO: Move this to a proprety with didset inside the view model
  func cityTitle(isShowingFullTitle: Bool) -> NSAttributedString {
    let cityName: String
    let upperDivisionText: String
    
    // City name disambiguation is sometimes presented in parentheses
    // Ex. the city of Fugging (Upper Austria)
    // We want to render as Fugging instead.
    let upperDivisionSuffix = isShowingFullTitle ? city.upperDivisionTitle : city.upperDivisionTitleWithAbbr
    let regex = try! NSRegularExpression(pattern: #"\s+\((.+)\)"#)
    let matches = regex.matches(in: city.name, range: city.name.entireRange)
    if let match = matches.first?.range(at: 1),
       let substringRange = Range(match, in: city.name) {
      let upperDivisionPrefix = String(city.name[substringRange])
      upperDivisionText = [upperDivisionPrefix, upperDivisionSuffix].joined(separator: ", ")
      cityName = city.name.replacingOccurrences(of: #"\s+\(.+\)"#, with: "", options: .regularExpression)
    } else {
      cityName = city.name
      upperDivisionText = upperDivisionSuffix
    }
    
    let mas = NSMutableAttributedString(string: "\(cityName) ")
    if let capitalDesignation = city.capitalDesignation {
      mas.append(.init(string: capitalDesignation, attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
                                                                .foregroundColor: UIColor.systemYellow]))
    }
    mas.append(.init(string: "\(upperDivisionText)\(city.countryFlag ?? "")", attributes: [.font: UIFont.systemFont(ofSize: UIFont.systemFontSize),
                                                                                     .foregroundColor: UIColor.systemGray]))
    
    return mas
  }
}
