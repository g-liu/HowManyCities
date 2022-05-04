//
//  BearingTests.swift
//  HowManyCitiesTests
//
//  Created by Geoffrey Liu on 5/4/22.
//

import Foundation
import XCTest
@testable import HowManyCities
import MapKit

final class BearingTests: XCTestCase {
  func testBearingFromDegreesNorth() {
    let degrees = 5.0
    let bearing = Bearing(rawValue: degrees)
    
    XCTAssertEqual(bearing, .n)
  }
  
  func testBearingFromDegreesNorthEast() {
    let degrees = 37.88
    let bearing = Bearing(rawValue: degrees)
    
    XCTAssertEqual(bearing, .ne)
  }
  
  func testBearingFromNegativeDegrees() {
    let degrees = -94.9
    let bearing = Bearing(rawValue: degrees)
    
    XCTAssertEqual(bearing, .w)
  }
  
  func testBearingFromGreaterThan360Degrees() {
    let degrees = 543.21
    let bearing = Bearing(rawValue: degrees)
    
    XCTAssertEqual(bearing, .s)
  }
  
  func testBearingOnBoundary() {
    let degrees = 247.5
    let bearing = Bearing(rawValue: degrees)
    
    XCTAssertEqual(bearing, .w)
    
    let degrees2 = 112.5
    let bearing2 = Bearing(rawValue: degrees2)
    
    XCTAssertEqual(bearing2, .se)
  }
  
  func testBearingOnCenter() {
    let degrees = 90.0
    let bearing = Bearing(rawValue: degrees)
    
    XCTAssertEqual(bearing, .e)
  }
}
