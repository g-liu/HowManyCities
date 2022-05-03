//
//  CityInfoViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit

class CityInfoViewController: UIViewController {
  var tempLabel = UILabel().autolayoutEnabled // TODO: Temporary of course
  
  var city: City? {
    didSet {
      configure(with: city)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(tempLabel)
    tempLabel.pin(to: view.safeAreaLayoutGuide)
    
    tempLabel.numberOfLines = 0
  }
  
  private func configure(with city: City?) {
    guard let city = city else {
      return
    }
    
    title = "\(city.countryFlag) \(city.nameWithStateAbbr)"
    navigationItem.title = "\(city.countryFlag) \(city.nameWithStateAbbr)"
    
    tempLabel.text = """
Name: \(city.name) \(city.capitalDesignation)
State: \(city.state)
Territory: \(city.territory)
Country: \(city.country)
Population: \(city.population)
Coordinates: \(city.coordinates)
Percent of people that guess this city: \(city.percentageOfSessions ?? 0.0)
"""
  }
  
}
