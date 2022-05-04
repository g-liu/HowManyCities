//
//  MapGuessModelTests.swift
//  HowManyCitiesTests
//
//  Created by Geoffrey Liu on 4/25/22.
//

import Foundation
import XCTest
@testable import HowManyCities
import MapKit

final class MapGuessModelTests: XCTestCase {
  func testMapGuessModelInit() {
    let model = MapGuessModel()
    
    XCTAssert(model.guessedCities.isEmpty)
    XCTAssertFalse(model.usedMultiCityInput)
    XCTAssertLessThanOrEqual(model.startTime, .now)
    XCTAssertNil(model.gameConfiguration)
    XCTAssertEqual(model.lastRegion, .init(center: .zero, span: .full))
    
    XCTAssertEqual(model.numCitiesGuessed, 0)
    XCTAssertEqual(model.populationGuessed, 0)
    XCTAssertEqual(model.percentageTotalPopulationGuessed, 0)
    XCTAssert(model.citiesByCountry.isEmpty)
    XCTAssert(model.citiesByTerritory.isEmpty)
    XCTAssert(model.nationalCapitalsGuessed.isEmpty)
    XCTAssert(model.largestCitiesGuessed.isEmpty)
    XCTAssert(model.smallestCitiesGuessed.isEmpty)
    XCTAssert(model.rarestCitiesGuessed.isEmpty)
    XCTAssert(model.citiesExceeding(population: 0).isEmpty)
  }
  
  func testMapGuessModelPopulationRatio() {
    var model = MapGuessModel()
    model.gameConfiguration = .init(totalPopulation: 37000)
    model.guessedCities.append(.init(name: "Geoville", population: 29500))
    
    XCTAssertEqual(model.percentageTotalPopulationGuessed, 29.5 / 37.0)
  }
  
  // TODO: Test with big ass datasets
}

extension MKCoordinateRegion: Equatable {
  public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
    lhs.center == rhs.center && lhs.span == rhs.span
  }
}

extension MKCoordinateSpan: Equatable {
  public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
    lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
  }
}
