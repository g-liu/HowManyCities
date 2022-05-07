//
//  DoubleExtensionTests.swift
//  HowManyCitiesTests
//
//  Created by Geoffrey Liu on 5/6/22.
//

import XCTest
@testable import HowManyCities

final class DoubleExtensionTests: XCTestCase {
  func testAsPercentCases() {
    // col 1: input. col 2: expected output
    let testCases = [1.00: "100%",
                     0.99: "99%",
                     0.986: "98.6%",
                     0.45000005: "45%",
                     0.378147329573: "37.8%",
                     0.2085: "20.9%", // FUCK YOU ROUND TO 20.9
                     0.10: "10%",
                     0.0999999: "10%",
                     0.037890123: "3.79%",
                     0.00827361: "0.827%",
                     0.000055555: "0.006%",
                     0.00000000001: "0.000000001%",
                     0.00000000000765: "0.0000000008%",
                     0.0: "0%"]
    for testCase in testCases {
      let pct = testCase.key.asPercentString
      XCTAssertEqual(pct, testCase.value)
    }
  }

}
