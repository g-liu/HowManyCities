//
//  GameStatsViewModel.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/10/22.
//

import Foundation
import UIKit

struct GameStatsViewModel {
  // TODO: ALL THESE sTRUCTTS ENUMS AND PROPERTIES NEED TO GET MOVED TO A VIEW MODEL OR SOMETHING
  // INSTEAD OF CLOGGING UP THE VC
  // AND IMPLEMENT CACHING FOR SOME OF THE CPU-HEAVY OPERATIONS
  // LIKE SORT, FILTER, OR MAP ON LARGE DATASETS!!!!!!
  struct ElementKind {
    static let header = "element-kind-header"
    static let buttonFooter = "element-kind-buttonFooter"
    static let textFooter = "element-kind-textFooter"
    static let pagingFooter = "element-kind-pagingFooter"
  }
  
  enum Section: Int, Hashable, CaseIterable, CustomStringConvertible {
    case cityList
    case stateList
    case territoryList
    case otherStats
    
    var description: String {
      switch self {
        case .cityList:
          return "Top cities"
        case .stateList:
          return "Top countries"
        case .territoryList:
          return "Top territories"
        case .otherStats:
          return "Other stats"
      }
    }
  }
  
  enum Item: Hashable {
    case ordinal(Int /* section index */, Int /* actual number */, Int /* another index for disambiguation in case of "ties" */)
    case city(City)
    case multiCity([City])
    case state(String /* state name */, [City])
    case formattedStat(Ratio, String)
    case emptyState(Section)
  }
  
  var showCitiesUpTo: Int = 10 {
    didSet {
      // NB: This could be far more efficient...
      // if we cache the COMPLETE cities list and just used .prefix(...) whenever we needed to
      var snapshot = dataSource.snapshot()
      refreshCityList(&snapshot)
      
      dataSource.apply(snapshot)
    }
  }
  
  var showStatesUpTo: Int = 10 {
    didSet {
      var snapshot = dataSource.snapshot()
      refreshStateList(&snapshot)
      
      dataSource.apply(snapshot)
    }
  }
  
  var showTerritoriesUpTo: Int = 10 {
    didSet {
      var snapshot = dataSource.snapshot()
      refreshTerritoryList(&snapshot)
      
      dataSource.apply(snapshot)
    }
  }
  
  // TODO: MOVE THE BELOW CODE TO A SEPARATE RENDERER????
  // OR at least the logic needs to be encapsulated elsewhere
  
  var citySortMode: CitySortMode = .populationDescending {
    didSet {
      var snapshot = dataSource.snapshot()
      refreshCityList(&snapshot)
      
      if oldValue.showsRarity != citySortMode.showsRarity {
        snapshot.reconfigureItems(inSection: .cityList)
      }
      // TODO: Is there a better way to toggle reload? Or avoid?
//      snapshot.reloadSections([.cityList])
      
      dataSource.apply(snapshot)
    }
  }
  
  var stateSortMode: StateSortMode = .cityCount {
    didSet {
      // TODO: DidSet to update UI was working when all this code was in UIVC... BUT
      // I don't think this will work anymore
      
      // Will have to bifurcate further and probably get rid of didSet for this purpose. 
      var snapshot = dataSource.snapshot()
      refreshStateList(&snapshot)
      refreshTerritoryList(&snapshot)
      
      snapshot.reconfigureItems(inSection: .stateList)
      snapshot.reconfigureItems(inSection: .territoryList)
      
      dataSource.apply(snapshot)
    }
  }
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  
  var statsProvider: GameStatisticsProvider?
  
//  init() {
//    setUpShit()
//  }
//
//  private func setUpShit() {
//
//  }
  
  init(statsProvider: GameStatisticsProvider) {
    self.statsProvider = statsProvider
  }
  
  /// Refresh city list
  /// - Parameter snapshot: The snapshot to apply to. If no snapshot provided, grabs a snapshot from the current dataSource
  /// - Returns: The snapshot with refreshed city list
  func refreshCityList(_ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
    snapshot.deleteItems(inSection: .cityList)
    
    guard let statsProvider = statsProvider else {
      snapshot.appendItems([.ordinal(0, 0, 0), .emptyState(.cityList)], toSection: .cityList)
      return
    }
    
    var items = [Item]()
    switch citySortMode {
      case .populationDescending:
        let intermediateList = statsProvider.citiesByPopulation.sorted(by: \.key, with: >).prefix(showCitiesUpTo)
        items = process(intermediateList)
      case .rarityAscending:
        let intermediateList = statsProvider.citiesByRarity.sorted(by: \.key).prefix(showCitiesUpTo)
        items = process(intermediateList)
      case .aToZ:
        let intermediateList = statsProvider.recentCitiesGuessed.sorted(by: \.fullTitle, with: { $0.localizedStandardCompare($1) == .orderedAscending }).prefix(showCitiesUpTo)
        intermediateList.enumerated().forEach {
          items.append(contentsOf: [.ordinal(0, $0+1, 0), .city($1)])
        }
      case .recent:
        let intermediateList = statsProvider.recentCitiesGuessed.prefix(showCitiesUpTo)
        intermediateList.enumerated().forEach {
          items.append(contentsOf: [.ordinal(0, $0+1, 0), .city($1)])
        }
        // shit's already sorted
        break
      case .countryAToZ:
        let intermediateList = statsProvider.recentCitiesGuessed.sorted {
          if $0.country == $1.country {
            return $0.fullTitle.localizedStandardCompare($1.fullTitle) == .orderedAscending
          } else {
            return $0.country.localizedStandardCompare($1.country) == .orderedAscending
          }
        }.prefix(showCitiesUpTo)
        intermediateList.enumerated().forEach {
          items.append(contentsOf: [.ordinal(0, $0+1, 0), .city($1)])
        }
    }

    if items.isEmpty {
      items.append(contentsOf: [.ordinal(0, 0, 0), .emptyState(.cityList)])
    }
    snapshot.appendItems(items, toSection: .cityList)
  }
  
  private func process<I/*TODO: There must be some way to constrain this*/>(_ segment: Array<I>.SubSequence) -> [Item] {
    var items: [Item] = .init()
    segment.enumerated().forEach {
      let ordinalNumber = $0 + 1
      items.append(.ordinal(0, ordinalNumber, 0))
      let cities: [City]
      if let dictEl = $1 as? Dictionary<Int, [City]>.Element {
        cities = dictEl.value
      } else if let dictEl = $1 as? Dictionary<Double, [City]>.Element {
        cities = dictEl.value
      } else {
        cities = []
      }
      
      if cities.count > 3 {
        items.append(.multiCity(cities))
      } else if !cities.isEmpty {
        items.removeLast()
        cities.enumerated().forEach { cityIndex, city in
          items.append(.ordinal(0, ordinalNumber, cityIndex))
          items.append(.city(city))
        }
      } else {
        print("WTF THIS SHOULD NEVER HAPPEN 2")
      }
    }
    
    return items
  }
   
  private func comparePopulation(_ lhs: (String, [City]), _ rhs: (String, [City])) -> Bool {
    if lhs.1.totalPopulation == rhs.1.totalPopulation {
      return lhs.0.localizedStandardCompare(rhs.0) == .orderedAscending
    } else {
      return lhs.1.totalPopulation > rhs.1.totalPopulation
    }
  }
  
  private func compareCityCount(_ lhs: (String, [City]), _ rhs: (String, [City])) -> Bool {
    if lhs.1.count == rhs.1.count {
      return lhs.0.localizedStandardCompare(rhs.0) == .orderedAscending
    } else {
      return lhs.1.count > rhs.1.count
    }
  }
  
  func refreshStateList(_ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
    snapshot.deleteItems(inSection: .stateList)
    
    guard let statsProvider = statsProvider,
          !statsProvider.citiesByCountry.isEmpty else {
      snapshot.appendItems([.ordinal(1, 0, 0), .emptyState(.stateList)], toSection: .stateList)
      return
    }
    
    let sortedStates: [(String, [City])]
    if stateSortMode == .cityCount {
      sortedStates = statsProvider.citiesByCountry.sorted(by: compareCityCount(_:_:))
    } else {
      sortedStates = statsProvider.citiesByCountry.sorted(by: comparePopulation(_:_:))
    }
      
    sortedStates.prefix(showStatesUpTo).enumerated().forEach {
      snapshot.appendItems([.ordinal(Section.stateList.rawValue, $0+1, 0), .state($1.0, $1.1)], toSection: .stateList)
    }
  }
  
  func refreshTerritoryList(_ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
    snapshot.deleteItems(inSection: .territoryList)
    
    guard let statsProvider = statsProvider,
          !statsProvider.citiesByTerritory.isEmpty else {
      snapshot.appendItems([.ordinal(2, 0, 0), .emptyState(.territoryList)], toSection: .territoryList)
      return
    }
    
    let sortedTerritories: [(String, [City])]
    if stateSortMode == .cityCount {
      sortedTerritories = statsProvider.citiesByTerritory.sorted(by: compareCityCount(_:_:))
    } else {
      sortedTerritories = statsProvider.citiesByTerritory.sorted(by: comparePopulation(_:_:))
    }
      
    sortedTerritories.prefix(showTerritoriesUpTo).enumerated().forEach {
      snapshot.appendItems([.ordinal(Section.territoryList.rawValue, $0+1, 0), .state($1.0, $1.1)], toSection: .territoryList)
    }
  }
  
  func refreshOtherStats(_ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
    snapshot.deleteItems(inSection: .otherStats)
    guard let statsProvider = statsProvider else { return }
    
    snapshot.appendItems(
      statsProvider.totalGuessedByBracket.map {
        Item.formattedStat($1, "cities over \($0.abbreviated)")
      } + [
        .formattedStat(statsProvider.totalStatesGuessed, "countries"),
        .formattedStat(statsProvider.totalCapitalsGuessed, "capitals"),
        .formattedStat(statsProvider.totalTerritoriesGuessed, "territories"),
      ], toSection: .otherStats)
  }
}
