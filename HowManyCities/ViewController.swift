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
    map.mapType = .mutedStandard
    map.isPitchEnabled = false
    map.isRotateEnabled = false
//    map.setCenter(.init(latitude: 0, longitude: 0), animated: true)
    map.setRegion(.init(center: .init(latitude: 0, longitude: 0), span: .init(latitudeDelta: 180, longitudeDelta: 360)), animated: true)
    map.setCameraZoomRange(.init(minCenterCoordinateDistance: 1000000), animated: true)
    map.removeAnnotations(map.annotations)
    map.pointOfInterestFilter = .excludingAll
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

