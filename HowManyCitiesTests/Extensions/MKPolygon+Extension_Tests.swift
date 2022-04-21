//
//  MKPolygon+Extension_Tests.swift
//  HowManyCitiesTests
//
//  Created by Geoffrey Liu on 4/21/22.
//

import Foundation
import XCTest
import MapKit
@testable import HowManyCities

final class MKPolygonExtensionTests: XCTestCase {
  func testCentroidOfPolygonWithOnePoint() {
    let polygon = MKPolygon(points: [.init(x: 5, y: 5)], count: 1)
    XCTAssertEqual(polygon.centroid, .init(x: 5, y: 5))
  }
  
  func testCentroidOfLineIsMiddle() {
    let polygon = MKPolygon(points: [.init(x: 0, y: 0),
                                     .init(x: 18, y: 5)], count: 2)
    
    XCTAssertEqual(polygon.centroid, .init(x: 9, y: 2.5))
  }
  
  func testCentroidOfSquareIsMiddleOfSquare() {
    let polygon = MKPolygon(points: [.init(x: -1, y: -1),
                                     .init(x: -1, y: 1),
                                     .init(x: 1, y: 1),
                                     .init(x: 1, y: -1)], count: 4)
    XCTAssertEqual(polygon.centroid, .init(x: 0, y: 0))
  }
}
