//
//  MKZoomScale+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/21/22.
//

import MapKit

extension MKZoomScale {
  var asLevel: Double {
    let totalTilesAtMaxZoom = MKMapSize.world.width / 256.0
    let zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom)
    
    return Swift.max(0.0, zoomLevelAtMaxZoom + log2(Double(self)))
  }
}
