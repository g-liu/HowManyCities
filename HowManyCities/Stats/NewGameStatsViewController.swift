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
  
  enum Section: Hashable {
    case cityList(CitySegment)
    case stateList
    case otherStats
  }
  
  enum Item: Hashable {
    case ordinal(Int /* section index */, Int /* actual number */)
    case city(City)
    case state(String /* state name */, [City])
    
//    case citiesByState(String, [String: [City]])
    case formattedStat(Ratio, String)
  }
  
  enum CitySegment: Int, CaseIterable {
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
    
    var title: String {
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
  
  var statsProvider: GameStatisticsProvider?
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  
  private lazy var collectionView: UICollectionView = {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { (sectionIndex, environment) -> NSCollectionLayoutSection? in
      if sectionIndex == 0 || sectionIndex == 1 {
        // TODO: How to make these two sizes be like.. [as-little-as-possible, remaining-width]?
        let ordinalItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.12), heightDimension: .estimated(1.0))
        let textItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.88), heightDimension: .estimated(1.0))
        
        let ordinalItem = NSCollectionLayoutItem(layoutSize: ordinalItemSize)
        let textItem = NSCollectionLayoutItem(layoutSize: textItemSize)
        
        ordinalItem.contentInsets = .zero
        textItem.contentInsets = .zero
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [ordinalItem, textItem])
        group.contentInsets = .zero
        
        let section = NSCollectionLayoutSection(group: group)
        
        let boundaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.header, alignment: .top)
        sectionHeader.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.buttonFooter, alignment: .bottom)
        sectionFooter.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        sectionFooter.pinToVisibleBounds = true
        
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        
        return section
      } /*else if sectionIndex == 1 {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .estimated(44.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let boundaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
//        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.header, alignment: .top)
//        sectionHeader.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
//        sectionHeader.pinToVisibleBounds = true
        
        // will be the paging view
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.pagingFooter, alignment: .bottom)
        sectionFooter.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        section.boundarySupplementaryItems = [sectionFooter]
        section.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        section.orthogonalScrollingBehavior = .paging
        
        section.visibleItemsInvalidationHandler = { visibleItems, offset, environment in
          // TODO: This only works if all pages are exactly the width of the cv
          let page = Int(round(offset.x / self.view.bounds.width))
          
          self.pagingInfoSubject.send(.init(currentPage: page))
        }
        
        // HOW THE FUCK DO I DO THIS
//        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
//          if let self = self, let lastVisibleItem = visibleItems.last {
//            var snapshot = self.dataSource.snapshot()
//            snapshot.reloadSections([.charts])
//              // TODO: How the fuck does this shit work, I want to change the fucking title ffs
//            DispatchQueue.main.async {
//              self.dataSource.apply(snapshot)
//            }
//          }
//        }
        
        return section
      } */else {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let boundaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.header, alignment: .top)
        sectionHeader.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        sectionHeader.pinToVisibleBounds = true
        
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.textFooter, alignment: .bottom)
        sectionFooter.contentInsets = .init(top: 8, leading: 8, bottom: 16, trailing: 8)
        
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        section.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        return section
      }
    }
    
    let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout).autolayoutEnabled
    cv.delegate = self
    
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
      let state = State(name: stateName)
      let mas = NSMutableAttributedString(string: "\(stateName)  ")
      if let flag = state.flag {
        mas.insert(.init(string: "\(flag) "), at: 0)
      }
      mas.append(.init(string: "\(cities.count)", attributes: [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                                                                   .foregroundColor: UIColor.systemGray]))
      configuration.attributedText = mas
      
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
    
//    let chartCellRegistration = UICollectionView.CellRegistration<ChartCollectionViewCell, Item> { cell, indexPath, itemIdentifier in
//      if case let .citiesByState(_, statesToCities) = itemIdentifier {
//        let title = indexPath.row == 0 ? "Top countries" : "Top territories"
//        cell.configure(title: title, data: statesToCities, threshold: 7)
//      }
//    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<CollectionViewHeaderReusableView>(elementKind: ElementKind.header) { supplementaryView, elementKind, indexPath in
      if indexPath.section == 0 {
        supplementaryView.text = self.selectedSegment.title
        // TODO: Persist selection
        supplementaryView.configureSegments(selectedSegmentIndex: self.selectedSegment.rawValue, segmentTitles: CitySegment.asNames)
        supplementaryView.segmentChangeDelegate = self
      } else if indexPath.section == 1 {
        supplementaryView.text = "Top countries"
      } else if indexPath.section == 2 {
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
    
//    let pagingFooterRegistration = UICollectionView.SupplementaryRegistration<PagingFooterCollectionReusableView>(elementKind: ElementKind.pagingFooter) { supplementaryView, elementKind, indexPath in
//      let itemCount = self.dataSource.snapshot().numberOfItems(inSection: .charts)
//      supplementaryView.configure(with: itemCount)
//
//      supplementaryView.subscribeTo(subject: self.pagingInfoSubject, for: indexPath.section)
//    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
      switch itemIdentifier {
        case .ordinal(let section, let index):
          return collectionView.dequeueConfiguredReusableCell(using: ordinalCellRegistration, for: indexPath, item: itemIdentifier)
        case .city(let city):
          return collectionView.dequeueConfiguredReusableCell(using: cityCellRegistration, for: indexPath, item: city)
        case .state(_, _):
          return collectionView.dequeueConfiguredReusableCell(using: stateCellRegistration, for: indexPath, item: itemIdentifier)
//        case .citiesByState(_, _):
//          return collectionView.dequeueConfiguredReusableCell(using: chartCellRegistration, for: indexPath, item: itemIdentifier)
        case .formattedStat(_, _):
          return collectionView.dequeueConfiguredReusableCell(using: ratioStatCellRegistration, for: indexPath, item: itemIdentifier)
      }
    })
    dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
      if elementKind == ElementKind.header /*|| elementKind == ElementKind.header2*/ {
        return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
      } else if elementKind == ElementKind.buttonFooter {
        return collectionView.dequeueConfiguredReusableSupplementary(using: buttonFooterRegistration, for: indexPath)
      } else if elementKind == ElementKind.textFooter {
        return collectionView.dequeueConfiguredReusableSupplementary(using: textFooterRegistration, for: indexPath)
      }/* else if elementKind == ElementKind.pagingFooter {
        return collectionView.dequeueConfiguredReusableSupplementary(using: pagingFooterRegistration, for: indexPath)
      }*/ else {
        return nil
      }
    }
    
    didChange(segmentIndex: 0)
    
    collectionView.dataSource = dataSource
  }
  
  @objc private func closeIt() {
    dismiss(animated: true)
  }
  
  private func applySnapshot() {
    // TODO: Very heavy-handed, wonder if we could update in a more graceful manner?
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.cityList(self.selectedSegment)])
    cities.enumerated().forEach {
      snapshot.appendItems([.ordinal(0, $0+1), $1])
    }
    
    if let statsProvider = statsProvider {
//      snapshot.appendSections([.charts])
//
//
//      snapshot.appendItems([.citiesByState("Countries", statsProvider.citiesByCountry),
//                            .citiesByState("Territories", statsProvider.citiesByTerritory)])
      
      snapshot.appendSections([.stateList])
      statsProvider.citiesByCountry.enumerated().forEach {
        snapshot.appendItems([.ordinal(1, $0+1), .state($1.key, $1.value)])
      }
//      snapshot.appendItems(statsProvider.citiesByCountry.map({ .state($0, $1) }))
      
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
  // TODO: WHY THE FUCK IS THIS NOT GETTING CALLED ON CERTAIN CELLS? WTF?????
  // OK IS IT JuST THE SIMULATOR PROBLEM
  // TODO: WHY IN THE FUCK IS THIS BEING CALLED WHEN TAPPING ON THE HEADER????
  // THAT DOESN'T EVEN MAKE SENSE AND IT'S ONLY HAPPENING ON SIM
  // TODO: OK FUCK YOU IPAD TOUCH!!!!!
  // WHY DO YOU HAVE TO BE SUCH A FUCKING PIECE OF SHIT
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


extension NewGameStatsViewController: SegmentChangeDelegate {
  func didChange(segmentIndex: Int) {
    let newSegment = CitySegment.init(rawValue: segmentIndex) ?? .recent
    self.selectedSegment = newSegment
    showUpTo = 10
    
    applySnapshot()
  }
  
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
}

extension NewGameStatsViewController: ToggleShowAllDelegate {
  func didToggle(_ isShowingAll: Bool) {
    self.showUpTo = isShowingAll ? Int.max : 10
    
    applySnapshot()
  }
}

