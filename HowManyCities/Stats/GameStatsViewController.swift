//
//  GameStatsViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit
//import Combine

final class GameStatsViewController: UIViewController {
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
  
//  private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
  
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
  
  enum CitySortMode: CaseIterable, CustomStringConvertible {
    case recent
    case aToZ
    case countryAToZ
    case populationDescending
    case rarityAscending
    
    var description: String {
      switch self {
        case .recent:
          return "Recent cities"
        case .aToZ:
          return "Cities A→Z"
        case .countryAToZ:
          return "Cities A→Z by country"
        case .populationDescending:
          return "Largest cities"
        case .rarityAscending:
          return "Rarest cities"
      }
    }
    
    // TODO: Could make ext?
    var nextMode: Self {
      let nextIndex = ((Self.allCases.firstIndex(of: self) ?? -1) + 1) % Self.allCases.count
      return Self.allCases[nextIndex]
    }
    
    var showsRarity: Bool {
      // TODO: Make this an ENUM or part of the renderer or SOMETHING needs to be more stateful!
      self == .rarityAscending
    }
  }
  
  enum StateSortMode: CaseIterable {
    case cityCount
    case population
    
    var nextMode: Self {
      let nextIndex = ((Self.allCases.firstIndex(of: self) ?? -1) + 1) % Self.allCases.count
      return Self.allCases[nextIndex]
    }
  }
  
  private var citySortMode: CitySortMode = .populationDescending {
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
  
  private var stateSortMode: StateSortMode = .cityCount {
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
      guard case let .ordinal(_, number, _) = itemIdentifier else { return }
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
      // TODO: I'll be back
      if self.citySortMode == .rarityAscending {
        configuration.attributedText = CityRarityRenderer().string(itemIdentifier)
      } else {
        configuration.attributedText = CityPopulationRenderer().string(itemIdentifier)
      }
      configuration.directionalLayoutMargins.leading = 0
      configuration.directionalLayoutMargins.trailing = 0
      
      cell.contentConfiguration = configuration
    }
    
    let multiCityCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, [City]> { cell, indexPath, itemIdentifier in
      var configuration = UIListContentConfiguration.cell()
      if self.citySortMode == .rarityAscending {
        configuration.attributedText = MultiCityRarityRenderer().string(itemIdentifier)
      } else {
        configuration.attributedText = MultiCityPopulationRenderer().string(itemIdentifier)
      }
      configuration.directionalLayoutMargins.leading = 0
      configuration.directionalLayoutMargins.trailing = 0
      cell.contentConfiguration = configuration
    }
    
    let stateCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, itemIdentifier in
      guard case let .state(stateName, cities) = itemIdentifier else {
        return
      }
      var configuration = UIListContentConfiguration.cell()
      
      switch self.stateSortMode {
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
    
    let emptyStateCellRegistration = UICollectionView.CellRegistration<EmptyStateCollectionViewCell, Section> { cell, indexPath, itemIdentifier in
      var configuration = UIListContentConfiguration.cell()
      configuration.textProperties.color = .systemGray
      configuration.textProperties.font = .italicSystemFont(ofSize: UIFont.labelFontSize)
//      configuration.textProperties.alignment = .center
      
      switch itemIdentifier {
        case .cityList:
          configuration.text = "You haven't guessed any cities yet.\nCities you guess will appear here."
        case .stateList:
          configuration.text = "You haven't guessed any countries yet.\nCountries of cities you guess will appear here."
        case .territoryList:
          configuration.text = "You haven't guessed any territories yet.\nTerritories of cities you guess will appear here."
        default:
          break
      }
      
      cell.contentConfiguration = configuration
    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<CollectionViewHeaderReusableView>(elementKind: ElementKind.header) { supplementaryView, elementKind, indexPath in
      supplementaryView.backgroundColor = .systemBackground
      
      guard let section = Section(rawValue: indexPath.section) else { return }
      supplementaryView.text = section.description
      
      switch section {
        case .cityList:
          // TODO: And we could reduce most/least populated into 1 segment, same with popular/rarest, and then in the third tab
          // can sort alphabetically, alphabetically by country, recently, or...
          // MAYBE JUST HAVE 1 CATEGORY WITH DIFFERENT SORTT OPTIONS?? LIKE F*CK THE SEGMENT
          supplementaryView.text = self.citySortMode.description
          supplementaryView.configure(sortCb: self.didTapSortCities)
        case .stateList, .territoryList:
          supplementaryView.configure(sortCb: self.didTapSortStates)
        case .otherStats:
          break
      }
    }
    
    let buttonFooterRegistration = UICollectionView.SupplementaryRegistration<FooterButtonCollectionReusableView>(elementKind: ElementKind.buttonFooter) { supplementaryView, elementKind, indexPath in
      guard let section = Section(rawValue: indexPath.section) else { return }
      supplementaryView.backgroundColor = .systemBackground
      supplementaryView.isHidden = false
      
      // TODO: This dependency on statsProvider is troubling, is there another way?
      
      switch section {
        case .cityList:
            guard (self.statsProvider?.recentCitiesGuessed.count ?? 0) > 10 else {
            supplementaryView.isHidden = true
            return
          }
          
          supplementaryView.configure(isShowingAll: self.showCitiesUpTo == Int.max) { isShowingAll in
            self.showCitiesUpTo = isShowingAll ? Int.max : 10
          }
        case .stateList:
          // NB: Is 20 because 1 cell for the ordinal, 1 cell for the actual content
//          supplementaryView.isHidden = self.dataSource.snapshot().numberOfItems(inSection: .stateList) <= 20
          supplementaryView.isHidden = self.statsProvider?.citiesByCountry.count ?? 0 <= 10
          supplementaryView.configure(isShowingAll: self.showStatesUpTo == Int.max) { isShowingAll in
            self.showStatesUpTo = isShowingAll ? Int.max : 10
          }
        case .territoryList:
//          supplementaryView.isHidden = self.dataSource.snapshot().numberOfItems(inSection: .territoryList) < 20
          supplementaryView.isHidden = self.statsProvider?.citiesByTerritory.count ?? 0 <= 10
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
        case .ordinal(_, _, _):
          return collectionView.dequeueConfiguredReusableCell(using: ordinalCellRegistration, for: indexPath, item: itemIdentifier)
        case .city(let city):
          return collectionView.dequeueConfiguredReusableCell(using: cityCellRegistration, for: indexPath, item: city)
        case .multiCity(let cities):
          return collectionView.dequeueConfiguredReusableCell(using: multiCityCellRegistration, for: indexPath, item: cities)
        case .state(_, _):
          return collectionView.dequeueConfiguredReusableCell(using: stateCellRegistration, for: indexPath, item: itemIdentifier)
        case .formattedStat(_, _):
          return collectionView.dequeueConfiguredReusableCell(using: ratioStatCellRegistration, for: indexPath, item: itemIdentifier)
        case .emptyState(let section):
          return collectionView.dequeueConfiguredReusableCell(using: emptyStateCellRegistration, for: indexPath, item: section)
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


extension GameStatsViewController: UICollectionViewDelegate {
  private func toggleHighlight(_ isOn: Bool, collectionView: UICollectionView, at indexPath: IndexPath) {
    let color: UIColor = isOn ? .systemFill : .clear
    guard let section = Section(rawValue: indexPath.section) else { return }
    let items = dataSource.snapshot().itemIdentifiers(inSection: section)
    
    if case .emptyState(_) = items[indexPath.row] {
      return // nothing to do here
    }
    
    switch section {
      case .cityList, .stateList, .territoryList:
        // also need to highlight the other index path
        var associatedIndexPath = indexPath
        if indexPath.row.isOdd {
          associatedIndexPath.row -= 1
        } else {
          // this is an ordinal
          associatedIndexPath.row += 1
          
          // check to see if we need highlight
          if case .emptyState(_) = items[associatedIndexPath.row] {
            return
          }
        }
        UIView.animate {
          self.collectionView.cellForItem(at: indexPath)?.backgroundColor = color
          self.collectionView.cellForItem(at: associatedIndexPath)?.backgroundColor = color
        }
      case .otherStats:
        UIView.animate {
          self.collectionView.cellForItem(at: indexPath)?.backgroundColor = color
        }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    toggleHighlight(true, collectionView: collectionView, at: indexPath)
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    toggleHighlight(false, collectionView: collectionView, at: indexPath)
  }
  
  // TODO: Figure out why the iPod touch simulator isn't calling this consistently
  // TODO: Disabled for now while we try to restructure the cells that display these cities
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let section = Section(rawValue: indexPath.section) else { return }
    let items = dataSource.snapshot().itemIdentifiers(inSection: section)
    let item = items[indexPath.row]
    
    switch section {
      case .cityList:
        switch item {
          case .multiCity(_):
            // TODO: HANDLE THIS CASE??!?!
            break
          case .ordinal(_, _, _):
            if case let .city(city) = items[indexPath.row + 1] {
              showCityVC(city)
            }
          case .city(let city):
            showCityVC(city)
          default:
            break // We can't handle this yet
        }

      case .stateList, .territoryList:
        
        switch item {
          case .ordinal(_, _, _):
            if case let .state(stateName, cities) = items[indexPath.row + 1] {
              showStateVC(.init(name: stateName), cities: cities)
            }
          case .state(let stateName, let cities):
            showStateVC(.init(name: stateName), cities: cities)
          default: break
        }

        
      default:
        break
    }
  }
  
  private func showCityVC(_ city: City) {
    let cityVC = CityInfoViewController()
    cityVC.statsProvider = statsProvider
    cityVC.city = city

    navigationController?.pushViewController(cityVC)
  }
  
  private func showStateVC(_ state: State, cities: [City]) {
    let stateVC = StateInfoViewController(state: state, guessedCities: cities)
    
    navigationController?.pushViewController(stateVC)
  }
}

// MARK: - Data source snapshot management
extension GameStatsViewController {
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
    // TODO: Will be back! Just have to implement a new way of sorting the cities in this list.
//    switch selectedSegment {
//    case .largest, .smallest:
//        let byPopulation = statsProvider.citiesByPopulation
//
//        guard !byPopulation.isEmpty else {
//          snapshot.appendItems([.ordinal(0, 0, 0), .emptyState(.cityList)], toSection: .cityList)
//          return
//        }
//
//        let sortedByPopulation = statsProvider.citiesByPopulation.sorted(by: \.key)
//        var populationSegment: Array<Dictionary<Int, [City]>.Element>.SubSequence // TODO: Y U SO COMPLEX TYPE
//        if selectedSegment == .largest {
//          populationSegment = sortedByPopulation.suffix(10)
//          populationSegment.reverse()
//        } else {
//          populationSegment = sortedByPopulation.prefix(10)
//        }
//
//        items = process(populationSegment)
//    case .rarest, .popular:
//        let byRarity = statsProvider.citiesByRarity
//
//        guard !byRarity.isEmpty else {
//          snapshot.appendItems([.ordinal(0, 0, 0), .emptyState(.cityList)], toSection: .cityList)
//          return
//        }
//
//        let sortedByRarity = byRarity.sorted(by: \.key)
//        var raritySegment: Array<Dictionary<Double, [City]>.Element>.SubSequence // TODO: Y U SO COMPLEX TYPE
//        if selectedSegment == .popular {
//          raritySegment = sortedByRarity.suffix(10)
//          raritySegment.reverse()
//        } else {
//          raritySegment = sortedByRarity.prefix(10)
//        }
//
//        items = process(raritySegment)
//    case .all:
        
//    var cityList: [City]
        
//        guard !recentGuessed.isEmpty else {
//          snapshot.appendItems([.ordinal(0, 0, 0), .emptyState(.cityList)], toSection: .cityList)
//          return
//        }
        
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
    
//    guard !cityList.isEmpty else {
//      snapshot.appendItems([.ordinal(0, 0, 0), .emptyState(.cityList)], toSection: .cityList)
//      return
//    }
//
//        cityList.prefix(showCitiesUpTo).enumerated().forEach {
//          items.append(.ordinal(0, $0 + 1, 0))
//          items.append(.city($1))
//        }
//    }
    
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

extension GameStatsViewController {
  func didTapSortCities() {
    citySortMode = citySortMode.nextMode
  }
  
  func didTapSortStates() {
    stateSortMode = stateSortMode.nextMode
  }
}

