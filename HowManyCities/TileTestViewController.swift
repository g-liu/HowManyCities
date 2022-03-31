//
//  TileTestViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/30/22.
//

import MapKit
import UIKit

final class TileTestViewController: UIViewController {
  private lazy var mapView: MKMapView = {
    let map = MKMapView().autolayoutEnabled
    map.mapType = .satellite
    
    map.delegate = self
    
    map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "MKAnnotationView")
    
    return map
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(mapView)
    mapView.pin(to: view)
    
//    let interfaceMode = traitCollection.userInterfaceStyle == .dark ? "dark" : "light"
//    let template = "https://a.basemaps.cartocdn.com/\(interfaceMode)_nolabels/{z}/{x}/{y}@2x.png"
    let template = "https://tiles.wmflabs.org/hillshading/{z}/{x}/{y}.png"

    let overlay = MKTileOverlay(urlTemplate: template)
    overlay.canReplaceMapContent = true
    mapView.addOverlay(overlay, level: .aboveLabels)
  }
}

extension TileTestViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let tileOverlay = overlay as? MKTileOverlay {
      return MKTileOverlayRenderer(tileOverlay: tileOverlay)
    }
    
    return .init(overlay: overlay)
  }
}
