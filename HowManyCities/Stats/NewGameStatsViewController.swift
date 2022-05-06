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
          return "Topp territories"
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
  
  var selectedSegment: CitySegment = .largest
  
  var showUpTo: Int = 10
  
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
  
  var stateRenderingMode: CountryRenderingMode = .cityCount {
    didSet {
      var snap = dataSource.snapshot()
      snap.reloadSections([.stateList])
      
      dataSource.apply(snap)
    }
  }
  
  var statsProvider: GameStatisticsProvider?
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  
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
        cityList = statsProvider?.recentCitiesGuessed.map(Item.city).prefix(showUpTo).asArray ?? []
      case .largest:
        fallthrough
      default:
        cityList = statsProvider?.largestCitiesGuessed.map(Item.city).prefix(10).asArray ?? []
    }
    
    return cityList
  }
  
  private lazy var collectionView: UICollectionView = {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { (sectionIndex, environment) -> NSCollectionLayoutSection? in
      if sectionIndex == 0 || sectionIndex == 1 || sectionIndex == 2 {
        // TODO: How to make these two sizes be like.. [as-little-as-possible, remaining-width]?
        let ordinalItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.12), heightDimension: .estimated(1.0))
        let textItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.88), heightDimension: .estimated(1.0))
        
        let ordinalItem = NSCollectionLayoutItem(layoutSize: ordinalItemSize)
        let textItem = NSCollectionLayoutItem(layoutSize: textItemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [ordinalItem, textItem])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let boundaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.header, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.buttonFooter, alignment: .bottom)
        sectionFooter.pinToVisibleBounds = true
        
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        
        return section
      } else {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
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
    
    // TODO: WHY THE FUCK DOES THIS SHIFT EVERYTHING TO THE RIGHT????
//    cv.contentInset = .init(top: 8.0, left: 16.0, bottom: 16.0, right: 16.0)
    
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
      // TODO: MOVE TO RENDERER
      guard case let .state(stateName, cities) = itemIdentifier else { return }
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
      if indexPath.section == 0 {
        supplementaryView.text = self.selectedSegment.description
        // TODO: Persist selection
        supplementaryView.configure(selectedSegmentIndex: self.selectedSegment.rawValue, segmentTitles: CitySegment.asNames)
      } else if indexPath.section == 1 {
        supplementaryView.text = "Top countries"
        supplementaryView.configure(selectedSegmentIndex: -1, segmentTitles: nil, showFilterButton: true)
      } else if indexPath.section == 2 {
        supplementaryView.text = "Top territories"
        supplementaryView.configure(selectedSegmentIndex: -1, segmentTitles: nil, showFilterButton: true)
      } else if indexPath.section == 3 {
        supplementaryView.text = "Other stats"
      }
      
      supplementaryView.backgroundColor = .systemBackground
    }
    
    let buttonFooterRegistration = UICollectionView.SupplementaryRegistration<FooterButtonCollectionReusableView>(elementKind: ElementKind.buttonFooter) { supplementaryView, elementKind, indexPath in
      guard self.selectedSegment == .recent else {
        supplementaryView.isHidden = true
        return
      }
      supplementaryView.isHidden = false
      supplementaryView.delegate = self
      supplementaryView.isShowingAll = self.showUpTo == Int.max ? true : false
      supplementaryView.backgroundColor = .systemBackground
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
    
//    didChange(segmentIndex: 0)
    applySnapshot()
    
    collectionView.dataSource = dataSource
  }
  
  @objc private func closeIt() {
    dismiss(animated: true)
  }
  
  private func applySnapshot() {
    // TODO: Very heavy-handed, wonder if we could update in a more graceful manner?
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.cityList])
    cities.enumerated().forEach {
      snapshot.appendItems([.ordinal(0, $0+1), $1])
    }
    
    if let statsProvider = statsProvider {
      snapshot.appendSections([.stateList])
      // TODO: Make these sorted lists persist
      statsProvider.citiesByCountry.sorted {
        if $0.value.count == $1.value.count {
          return $0.key.localizedStandardCompare($1.key) == .orderedAscending
        } else {
          return $0.value.count > $1.value.count
        }
      }.enumerated().forEach {
        snapshot.appendItems([.ordinal(1, $0+1), .state($1.key, $1.value)])
      }
      
      snapshot.appendSections([.territoryList])
      statsProvider.citiesByTerritory.sorted {
        if $0.value.count == $1.value.count {
          return $0.key.localizedStandardCompare($1.key) == .orderedAscending
        } else {
          return $0.value.count > $1.value.count
        }
      }.enumerated().forEach {
        snapshot.appendItems([.ordinal(2, $0+1), .state($1.key, $1.value)])
      }
      
      snapshot.appendSections([.otherStats])
      snapshot.appendItems(
        statsProvider.totalGuessedByBracket.map {
          Item.formattedStat($1, "cities over \($0.abbreviated)")
        } + [
          .formattedStat(statsProvider.totalStatesGuessed, "countries"),
          .formattedStat(statsProvider.totalCapitalsGuessed, "capitals"),
          .formattedStat(statsProvider.totalTerritoriesGuessed, "territories"),
        ]
      )
    }
    
    dataSource.apply(snapshot, animatingDifferences: true)
  }
}


extension NewGameStatsViewController: UICollectionViewDelegate {
  // TODO: Figure out why the iPod touch simulator isn't calling this consistently
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // If it's a city, open the city page
    if indexPath.section == 0 {
      // open page
      let cityVC = CityInfoViewController()
      cityVC.statsProvider = statsProvider
      if case let .city(city) = cities[(indexPath.row - indexPath.row%2) / 2] {
        cityVC.city = city
      }
      
      navigationController?.pushViewController(cityVC)
    }
  }
}


extension NewGameStatsViewController: SectionChangeDelegate {
  func didChange(segmentIndex: Int) {
    let newSegment = CitySegment.init(rawValue: segmentIndex) ?? .recent
    self.selectedSegment = newSegment
    showUpTo = 10
    
    // TODO: New code plz validate
    var snapshot = dataSource.snapshot()
    snapshot.reloadSections([.cityList])
    
    dataSource.apply(snapshot)
  }
  
  func didTapFilter() {
    stateRenderingMode = stateRenderingMode.nextMode
  }
}

extension NewGameStatsViewController: ToggleShowAllDelegate {
  func didToggle(_ isShowingAll: Bool) {
    self.showUpTo = isShowingAll ? Int.max : 10
    
    applySnapshot() // TODO: Better way???
  }
}

