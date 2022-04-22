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
  func testAreaOfEmptyPolygonIsZero() {
    let polygon = MKPolygon(points: [], count: 0)
    XCTAssertEqual(polygon.area, 0)
  }
  
  func testAreaOfPointIsZero() {
    let polygon = MKPolygon(points: [.init(x: 3, y: 3)], count: 1)
    XCTAssertEqual(polygon.area, 0)
  }
  
  func testAreaOfLineIsZero() {
    let polygon = MKPolygon(points: [.init(x: -4, y: 7), .init(x: 7, y: -4)], count: 2)
    XCTAssertEqual(polygon.area, 0)
  }
  
  func testAreaOfSquare() {
    let polygon = MKPolygon(points: [.init(x: 0, y: 0),
                                     .init(x: 1, y: 0),
                                     .init(x: 1, y: 1),
                                     .init(x: 0, y: 1)], count: 4)
    XCTAssertEqual(polygon.area, 1)
  }
  
  func testAreaOfIrregularPolygon() {
    // https://www.wolframalpha.com/input?i=area+of+%28-10%2C+-1%29%2C+%28-3%2C+-5%29%2C+%284%2C+-7%29%2C+%2810%2C2%29%2C+%283%2C0%29
    let polygon = MKPolygon(points: [.init(x: -10, y: -1),
                                     .init(x: -3, y: -5),
                                     .init(x: 4, y: -7),
                                     .init(x: 10, y: 2),
                                     .init(x: 3, y: 0)], count: 5)
    XCTAssertEqual(polygon.area, 78.5) // Trust me I'm an engineer
  }
  
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
  
  func testCentroidOfRightTriangle() {
    let polygon = MKPolygon(points: [.init(x: 0, y: 0),
                                     .init(x: 10, y: 0),
                                     .init(x: 10, y: 10)], count: 3)
    
    XCTAssertEqual(polygon.centroid, .init(x: 6+2.0/3.0, y: 3+1.0/3.0))
  }
  
  func testCentroidOfIrregularPolygon() {
    // https://www.wolframalpha.com/input?i=centroid+of+polygon++%28-10%2C+-1%29%2C+%28-3%2C+-5%29%2C+%284%2C+-7%29%2C+%2810%2C2%29%2C+%283%2C0%29
    let polygon = MKPolygon(points: [.init(x: -10, y: -1),
                                     .init(x: -3, y: -5),
                                     .init(x: 4, y: -7),
                                     .init(x: 10, y: 2),
                                     .init(x: 3, y: 0)], count: 5)
    XCTAssertEqual(polygon.centroid, .init(x: 155.0/157.0, y: -391.0/157.0)) // Trust me I'm an engineer
  }
}
