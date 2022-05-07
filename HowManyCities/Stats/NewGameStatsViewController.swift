//
//  NewGameStatsViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit
import Charts
import Combine

final class NewGameStatsViewController: UIViewController {
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
    case ordinal(Int /* section index */, Int /* actual number */)
    case city(City)
    case state(String /* state name */, [City])
    case formattedStat(Ratio, String)
  }
  
  enum CitySegment: Int, CaseIterable, CustomStringConvertible {
    case largest
    case smallest
    case rarest
    case mostCommon
    case recent
    
    var name: String {
      switch self {
        case .largest: return "Largest"
        case .smallest: return "Smallest"
        case .rarest: return "Rarest"
        case .mostCommon: return "Common"
        case .recent: return "Recent"
      }
    }
    
    var description: String {
      switch self {
        case .largest: return "Largest cities"
        case .smallest: return "Smallest cities"
        case .rarest: return "Rarest guessed"
        case .mostCommon: return "Commonly guessed"
        case .recent: return "Your cities"
      }
    }
    
    static var asNames: [String] {
      allCases.map { $0.name }
    }
  }
  
  private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
  
  private var selectedSegment: CitySegment = .largest
  
  private var showCitiesUpTo: Int = 10 {
    didSet {
      var snapshot = dataSource.snapshot()
      refreshCityList(&snapshot)
      
      dataSource.apply(snapshot)
    }
  }
  
  private var showStatesUpTo: Int = 10 {
    didSet {
      var snapshot = dataSource.snapshot()
      refreshStateList(&snapshot)
      
      dataSource.apply(snapshot)
    }
  }
  
  private var showTerritoriesUpTo: Int = 10 {
    didSet {
      var snapshot = dataSource.snapshot()
      refreshTerritoryList(&snapshot)
      
      dataSource.apply(snapshot)
    }
  }
  
  // TODO: MOVE THE BELOW CODE TO A SEPARATE RENDERER????
  // OR at least the logic needs to be encapsulated elsewhere
  enum CountryRenderingMode: CaseIterable {
    case cityCount
    case population
    
    var nextMode: Self {
      // TODO: Shit impl but this will suffice 4 now
      if self == .cityCount { return .population }
      else { return .cityCount }
    }
  }
  
  private var stateRenderingMode: CountryRenderingMode = .cityCount {
    didSet {
      var snapshot = dataSource.snapshot()
      refreshStateList(&snapshot)
      refreshTerritoryList(&snapshot)
      
      snapshot.reconfigureItems(inSection: .stateList)
      snapshot.reconfigureItems(inSection: .territoryList)
      
      dataSource.apply(snapshot)
    }
  }
  
  var statsProvider: GameStatisticsProvider?
  
  private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  
  private var cities: [Item] {
    let cityList: [Item]
    switch selectedSegment {
      case .smallest:
        cityList = statsProvider?.smallestCitiesGuessed.map(Item.city).prefix(10).asArray ?? []
      case .rarest:
        cityList = statsProvider?.rarestCitiesGuessed.map(Item.city).prefix(10).asArray ?? []
      case .mostCommon:
        cityList = statsProvider?.commonCitiesGuessed.map(Item.city).prefix(10).asArray ?? []
      case .recent:
        cityList = statsProvider?.recentCitiesGuessed.map(Item.city).prefix(showCitiesUpTo).asArray ?? []
      case .largest:
        fallthrough
      default:
        cityList = statsProvider?.largestCitiesGuessed.map(Item.city).prefix(10).asArray ?? []
    }
    
    return cityList
  }
  
  private lazy var collectionView: UICollectionView = {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { (sectionIndex, environment) -> NSCollectionLayoutSection? in
      guard let section = Section(rawValue: sectionIndex) else { return nil }
      switch section {
        case .cityList,
            .stateList,
            .territoryList:
          // TODO: How to make these two sizes be like.. [as-little-as-possible, remaining-width]?
          let ordinalItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.12), heightDimension: .estimated(1.0))
          let textItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.88), heightDimension: .estimated(1.0))
          
          let ordinalItem = NSCollectionLayoutItem(layoutSize: ordinalItemSize)
          let textItem = NSCollectionLayoutItem(layoutSize: textItemSize)
          
          let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
          let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [ordinalItem, textItem])
          
          let section = NSCollectionLayoutSection(group: group)
          section.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
          section.supplementariesFollowContentInsets = false
          
          let boundaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
          let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.header, alignment: .top)
          sectionHeader.pinToVisibleBounds = true
          
          let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.buttonFooter, alignment: .bottom)
          sectionFooter.pinToVisibleBounds = true
          
          section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
          
          return section
        case .otherStats:
          let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
          let item = NSCollectionLayoutItem(layoutSize: itemSize)
          
          let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
          let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
          
          let section = NSCollectionLayoutSection(group: group)
          section.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
          section.supplementariesFollowContentInsets = false
          
          let boundaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
          let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.header, alignment: .top)
          sectionHeader.pinToVisibleBounds = true
          
          let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.textFooter, alignment: .bottom)
          
          section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
          
          return section
      }
    }
    
    let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout).autolayoutEnabled
    cv.delegate = self
    cv.allowsSelection = true
    
    // TODO: WHY THE FUCK DOES THIS SHIFT EVERYTHING TO THE RIGHT????
    // FUCK YOU COLLECTION VIEW
//    cv.insetsLayoutMarginsFromSafeArea = false
//    cv.layoutMargins = .init(top: 8, left: 16, bottom: 0, right: 16)
//    cv.contentInset = .init(top: 8.0, left: 16.0, bottom: 16.0, right: 16.0)
//    cv.contentInsetAdjustmentBehavior = .scrollableAxes
//    cv.safeAreaInsets = .init(top: 8, left: 16, bottom: 16, right: 16)
    return cv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureHierarchy()
    configureDataSource()
  }
  
  private func configureHierarchy() {
    title = "Statistics"
    navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(closeIt))
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(collectionView)
    collectionView.pin(to: view.safeAreaLayoutGuide)
  }
  
  // MARK: Data source, registration, headers/footers, cells
  private func configureDataSource() {
    let ordinalCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, itemIdentifier in
      guard case let .ordinal(_, number) = itemIdentifier else { return }
      var configuration = UIListContentConfiguration.cell()
      configuration.text = "\(number)."
      configuration.textProperties.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
      configuration.textProperties.color = .systemGray
      configuration.directionalLayoutMargins = .zero
      
      cell.contentConfiguration = configuration
      cell.contentView.layoutMargins = .zero
    }
    
    let cityCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, City> { cell, indexPath, itemIdentifier in
      var configuration = UIListContentConfiguration.cell()
      if self.selectedSegment == .rarest || self.selectedSegment == .mostCommon {
        configuration.attributedText = CityRarityRenderer().string(itemIdentifier)
      } else {
        configuration.attributedText = CityPopulationRenderer().string(itemIdentifier)
      }
      configuration.directionalLayoutMargins = .zero
      
      cell.contentConfiguration = configuration
    }
    
    let stateCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, itemIdentifier in
      guard case let .state(stateName, cities) = itemIdentifier else {
        return
      }
      var configuration = UIListContentConfiguration.cell()
      
      switch self.stateRenderingMode {
        case .population:
          configuration.attributedText = StateTotalPopulationRenderer().string((stateName, cities))
        case .cityCount:
          configuration.attributedText = StateCityCountRenderer().string((stateName, cities))
      }
      
      cell.contentConfiguration = configuration
    }
    
    let ratioStatCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, itemIdentifier in
      guard case let .formattedStat(ratio, description) = itemIdentifier else { return }
      var configuration = UIListContentConfiguration.cell()
      
      // TODO: Localize
      let mas = NSMutableAttributedString(string: "\(ratio.numerator)", attributes: [.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)])
      mas.append(.init(string: " of "))
      mas.append(.init(string: "\(ratio.denominator)", attributes: [.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)]))
      mas.append(.init(string: " \(description)"))
      
      configuration.attributedText = mas
      
      cell.contentConfiguration = configuration
    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<CollectionViewHeaderReusableView>(elementKind: ElementKind.header) { supplementaryView, elementKind, indexPath in
      supplementaryView.delegate = self
      supplementaryView.backgroundColor = .systemBackground
      
      guard let section = Section(rawValue: indexPath.section) else { return }
      supplementaryView.text = section.description
      
      switch section {
        case .cityList:
          supplementaryView.text = self.selectedSegment.description
          supplementaryView.configure(selectedSegmentIndex: self.selectedSegment.rawValue, segmentTitles: CitySegment.asNames)
        case .stateList, .territoryList:
          supplementaryView.configure { self.didTapSort() }
        case .otherStats:
          break
      }
    }
    
    let buttonFooterRegistration = UICollectionView.SupplementaryRegistration<FooterButtonCollectionReusableView>(elementKind: ElementKind.buttonFooter) { supplementaryView, elementKind, indexPath in
      guard let section = Section(rawValue: indexPath.section) else { return }
      supplementaryView.backgroundColor = .systemBackground
      supplementaryView.isHidden = false
      
      switch section {
        case .cityList:
          guard self.selectedSegment == .recent else {
            supplementaryView.isHidden = true
            return
          }
          
          supplementaryView.configure(isShowingAll: self.showCitiesUpTo == Int.max) { isShowingAll in
            self.showCitiesUpTo = isShowingAll ? Int.max : 10
          }
        case .stateList:
          supplementaryView.configure(isShowingAll: self.showStatesUpTo == Int.max) { isShowingAll in
            self.showStatesUpTo = isShowingAll ? Int.max : 10
          }
        case .territoryList:
          supplementaryView.configure(isShowingAll: self.showTerritoriesUpTo == Int.max) { isShowingAll in
            self.showTerritoriesUpTo = isShowingAll ? Int.max : 10
          }
        case .otherStats:
          break
      }
    }
    
    let textFooterRegistration = UICollectionView.SupplementaryRegistration<FooterTextCollectionReusableView>(elementKind: ElementKind.textFooter) { supplementaryView, elementKind, indexPath in
      supplementaryView.configure(text: "Save your results to see what you missed.")
      supplementaryView.backgroundColor = .systemBackground
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
      switch itemIdentifier {
        case .ordinal(_, _):
          return collectionView.dequeueConfiguredReusableCell(using: ordinalCellRegistration, for: indexPath, item: itemIdentifier)
        case .city(let city):
          return collectionView.dequeueConfiguredReusableCell(using: cityCellRegistration, for: indexPath, item: city)
        case .state(_, _):
          return collectionView.dequeueConfiguredReusableCell(using: stateCellRegistration, for: indexPath, item: itemIdentifier)
        case .formattedStat(_, _):
          return collectionView.dequeueConfiguredReusableCell(using: ratioStatCellRegistration, for: indexPath, item: itemIdentifier)
      }
    })
    dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
      if elementKind == ElementKind.header {
        return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
      } else if elementKind == ElementKind.buttonFooter {
        return collectionView.dequeueConfiguredReusableSupplementary(using: buttonFooterRegistration, for: indexPath)
      } else if elementKind == ElementKind.textFooter {
        return collectionView.dequeueConfiguredReusableSupplementary(using: textFooterRegistration, for: indexPath)
      } else {
        return nil
      }
    }
    
    populateInitialData()
    
    collectionView.dataSource = dataSource
  }
  
  @objc private func closeIt() {
    dismiss(animated: true)
  }
  
  private func populateInitialData() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.cityList, .stateList, .territoryList, .otherStats])
    
    refreshCityList(&snapshot)
    refreshStateList(&snapshot)
    refreshTerritoryList(&snapshot)
    refreshOtherStats(&snapshot)
    
    dataSource.apply(snapshot, animatingDifferences: true)
  }
}


extension NewGameStatsViewController: UICollectionViewDelegate {
  private func toggleHighlight(_ isOn: Bool, collectionView: UICollectionView, at indexPath: IndexPath) {
    let color: UIColor = isOn ? .systemFill : .clear
    
    switch Section(rawValue: indexPath.section) {
      case .cityList, .stateList, .territoryList:
        // also need to highlight the other index path
        var associatedIndexPath = indexPath
        if indexPath.row.isOdd {
          associatedIndexPath.row -= 1
        } else {
          associatedIndexPath.row += 1
        }
        UIView.animate {
          self.collectionView.cellForItem(at: indexPath)?.backgroundColor = color
          self.collectionView.cellForItem(at: associatedIndexPath)?.backgroundColor = color
        }
      case .otherStats:
        UIView.animate {
          self.collectionView.cellForItem(at: indexPath)?.backgroundColor = color
        }
      case .none: break
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    toggleHighlight(true, collectionView: collectionView, at: indexPath)
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    toggleHighlight(false, collectionView: collectionView, at: indexPath)
  }
  
  // TODO: Figure out why the iPod touch simulator isn't calling this consistently
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let section = Section(rawValue: indexPath.section) else { return }
    switch section {
      case .cityList:
        let cityVC = CityInfoViewController()
        cityVC.statsProvider = statsProvider
        if case let .city(city) = cities[(indexPath.row - indexPath.row%2) / 2] {
          cityVC.city = city
        }
        
        navigationController?.pushViewController(cityVC)
        // TODO: Coming soon...
        //      case .stateList,
//          .territoryList:
//        let stateVC = StateInfoViewController()
//        stateVC.state = /* ???? */
//
//        navigationController?.pushViewController(stateVC)
      default:
        break
    }
  }
}

// MARK: - Data source snapshot management
extension NewGameStatsViewController {
  /// Refresh city list
  /// - Parameter snapshot: The snapshot to apply to. If no snapshot provided, grabs a snapshot from the current dataSource
  /// - Returns: The snapshot with refreshed city list
  func refreshCityList(_ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
    snapshot.deleteItems(inSection: .cityList)
    cities.enumerated().forEach {
      snapshot.appendItems([.ordinal(0, $0+1), $1], toSection: .cityList)
    }
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
    guard let statsProvider = statsProvider else { return }
    
    snapshot.deleteItems(inSection: .stateList)
    let sortedStates: [(String, [City])]
    if stateRenderingMode == .cityCount {
      sortedStates = statsProvider.citiesByCountry.sorted(by: compareCityCount(_:_:))
    } else {
      sortedStates = statsProvider.citiesByCountry.sorted(by: comparePopulation(_:_:))
    }
      
    sortedStates.prefix(showStatesUpTo).enumerated().forEach {
      snapshot.appendItems([.ordinal(Section.stateList.rawValue, $0+1), .state($1.0, $1.1)], toSection: .stateList)
    }
  }
  
  func refreshTerritoryList(_ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
    guard let statsProvider = statsProvider else { return }
    
    snapshot.deleteItems(inSection: .territoryList)
    let sortedTerritories: [(String, [City])]
    if stateRenderingMode == .cityCount {
      sortedTerritories = statsProvider.citiesByTerritory.sorted(by: compareCityCount(_:_:))
    } else {
      sortedTerritories = statsProvider.citiesByTerritory.sorted(by: comparePopulation(_:_:))
    }
      
    sortedTerritories.prefix(showTerritoriesUpTo).enumerated().forEach {
      snapshot.appendItems([.ordinal(Section.territoryList.rawValue, $0+1), .state($1.0, $1.1)], toSection: .territoryList)
    }
  }
  
  func refreshOtherStats(_ snapshot: inout NSDiffableDataSourceSnapshot<Section, Item>) {
    guard let statsProvider = statsProvider else { return }
    snapshot.deleteItems(inSection: .otherStats)
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

extension NewGameStatsViewController: SectionChangeDelegate {
  func didChange(segmentIndex: Int) {
    let newSegment = CitySegment.init(rawValue: segmentIndex) ?? .recent
    self.selectedSegment = newSegment
    showCitiesUpTo = 10
    
    var snapshot = dataSource.snapshot()
    refreshCityList(&snapshot)
    snapshot.reloadSections([.cityList])
    
    dataSource.apply(snapshot)
  }
  
  func didTapSort() {
    stateRenderingMode = stateRenderingMode.nextMode
  }
}

