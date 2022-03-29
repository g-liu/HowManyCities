//
//  ViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import UIKit
import MapKit

final class ViewController: UIViewController {
  
  private lazy var mapView: MKMapView = {
    let map = MKMapView().autolayoutEnabled
    
    return map
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(mapView)
    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
    ])
  }


}

