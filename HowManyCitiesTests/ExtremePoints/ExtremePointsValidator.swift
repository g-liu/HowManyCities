//
//  ExtremePointsValidator.swift
//  HowManyCitiesTests
//
//  Created by Geoffrey Liu on 4/26/22.
//

import XCTest
@testable import HowManyCities
import CoreLocation

final class ExtremePointsValidator: XCTestCase {
  func test_validate() throws {
    let bundle = Bundle(for: StatePickerViewController.self)
    let extremePointsUrl = bundle.url(forResource: "ExtremePointsOfCountries", withExtension: "plist")!
    
    do {
      let data = try Data(contentsOf: extremePointsUrl)
      let decoder = PropertyListDecoder()
      let extremePoints = try decoder.decode([String: [String: String]].self, from: data)
      
      var stateBorderLines = [String: BorderLines]()
      
      let northernmost = extremePoints["Northernmost"]!
      let southernmost = extremePoints["Southernmost"]!
      let easternmost = extremePoints["Easternmost"]!
      let westernmost = extremePoints["Westernmost"]!
      
      XCTAssert(!northernmost.isEmpty)
      XCTAssert(!southernmost.isEmpty)
      XCTAssert(!easternmost.isEmpty)
      XCTAssert(!westernmost.isEmpty)
      
      northernmost.forEach {
        let stateName = $0
        let boundary = $1.asDegrees
        
        // TODO: THIS SOME FUCKING BULLSHIT
        if let _ = stateBorderLines[stateName] {
          stateBorderLines[stateName]?.north = boundary
        } else {
          stateBorderLines[stateName] = .init()
          stateBorderLines[stateName]?.north = boundary
        }
//        stateBorderLines[stateName, default: .init()].north = boundary
      }
      
      southernmost.forEach {
        let stateName = $0
        let boundary = $1.asDegrees
        
        if let _ = stateBorderLines[stateName] {
          stateBorderLines[stateName]?.south = boundary
        } else {
          stateBorderLines[stateName] = .init()
          stateBorderLines[stateName]?.south = boundary
        }
//        stateBorderLines[stateName, default: .init()].south = boundary
      }
      
      easternmost.forEach {
        let stateName = $0
        let boundary = $1.asDegrees
        
        if let _ = stateBorderLines[stateName] {
          stateBorderLines[stateName]?.east = boundary
        } else {
          stateBorderLines[stateName] = .init()
          stateBorderLines[stateName]?.east = boundary
        }
//        stateBorderLines[stateName, default: .init()].east = boundary
      }
      
      westernmost.forEach {
        let stateName = $0
        let boundary = $1.asDegrees
        
        if let _ = stateBorderLines[stateName] {
          stateBorderLines[stateName]?.west = boundary
        } else {
          stateBorderLines[stateName] = .init()
          stateBorderLines[stateName]?.west = boundary
        }
        stateBorderLines[stateName, default: .init()].west = boundary
      }
      
      let stateCorners = stateBorderLines.map {
        ($0.key, $0.value.asCorners)
      }
      
      print(stateCorners)
      
    } catch {
      XCTFail("VALIDATION FAILED COULD NOT READ FILE")
    }
  }
}

struct BorderLines {
//  var north: CLLocationDegrees? = nil
//  var south: CLLocationDegrees? = nil
//  var east: CLLocationDegrees? = nil
//  var west: CLLocationDegrees? = nil
  
  var north: CLLocationDegrees
  var south: CLLocationDegrees
  var east: CLLocationDegrees
  var west: CLLocationDegrees
  
  init(north: CLLocationDegrees = .zero,
       south: CLLocationDegrees = .zero,
       east: CLLocationDegrees = .zero,
       west: CLLocationDegrees = .zero) {
    self.north = north
    self.south = south
    self.east = east
    self.west = west
  }
  
  var asCorners: CLLocationCorners {
//    guard let north = north,
//          let south = south,
//          let east = east,
//          let west = west else {
//
//    }
    .init(northwest: .init(latitude: north, longitude: west), southeast: .init(latitude: south, longitude: east))
  }
}

struct CLLocationCorners {
  let northwest: CLLocationCoordinate2D
  let southeast: CLLocationCoordinate2D
}

extension String {
  var asDegrees: CLLocationDegrees {
    // string is of format XX°XX′XX″[NESW]
    guard let direction = last else {
      XCTFail("EMPTY STRING??? \(self)")
      return .zero
    }

    let sign: Int
    if direction == "S" || direction == "W" {
      sign = -1
    } else {
      sign = 1
    }

    let firstComponents = split(separator: "°")
    let degreesString = String(firstComponents.first ?? "")
    guard let degrees = Double(degreesString) else {
      XCTFail("FAIL: could not convert \(degreesString) to numerical degrees")
      return .zero
    }

    let nextComponents = firstComponents[1].split(separator: "′")
    let minutesString = String(nextComponents.first ?? "")
    guard let minutes = Double(minutesString) else {
      return sign * degrees
    }

    let lastComponents = nextComponents[1].split(separator: "″")
    let secondsString = String(lastComponents.first ?? "")
    guard let seconds = Double(secondsString) else {
      return sign * (degrees + minutes / 60.0)
    }

    return sign * (degrees + minutes / 60.0 + seconds / 3600.0)
  }
}
