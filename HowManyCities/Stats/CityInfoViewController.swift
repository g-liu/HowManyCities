//
//  CityInfoViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit

class CityInfoViewController: UIViewController {
  var tempLabel = UILabel() // TODO: Temporary of course
  
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
  }
  
  private func configure(with city: City?) {
    guard let city = city else {
      return
    }
    
    title = city.fullTitle
    navigationItem.title = city.fullTitle
    
    tempLabel.text = """
Name: \(city.fullTitle) \(city.capitalDesignation)

Population: \(city.population)

Coordinates: \(city.coordinates)

Percent of people that guess this city: \(city.percentageOfSessions ?? 0.0)
"""
  }
  
}
