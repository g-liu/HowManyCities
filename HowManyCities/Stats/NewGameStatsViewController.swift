//
//  NewGameStatsViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit

final class NewGameStatsViewController: UIViewController {
  struct ElementKind {
    static let header = "element-kind-header"
//    static let header2 = "element-kind-header2"
    static let footer = "element-kind-footer"
  }
  
  enum Section: Hashable {
    case cityList(CitySegment)
    case citiesByCountry
    case otherStats
  }
  
  enum Item: Hashable {
    case ordinal(Int)
    case city(City)
    
    case citiesByState([String: [City]])
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
  
  var selectedSegment: CitySegment = .largest
  
  var showUpTo: Int = 10
  
  var statsProvider: GameStatisticsProvider?
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  
  private lazy var collectionView: UICollectionView = {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { (sectionIndex, environment) -> NSCollectionLayoutSection? in
      if sectionIndex == 0 {
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
        sectionHeader.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.footer, alignment: .bottom)
        sectionFooter.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        section.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        return section
      } else {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let boundaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: ElementKind.header, alignment: .top)
        sectionHeader.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        section.boundarySupplementaryItems = [sectionHeader]
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
    let ordinalCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Int> { cell, indexPath, itemIdentifier in
      var configuration = UIListContentConfiguration.cell()
      configuration.text = "\(itemIdentifier)."
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
      cell.contentView.layoutMargins = .zero
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
      if indexPath.section == 0 {
        supplementaryView.text = self.selectedSegment.title
        // TODO: Persist selection
        supplementaryView.configure(selectedSegmentIndex: self.selectedSegment.rawValue, segmentTitles: CitySegment.asNames)
        supplementaryView.segmentChangeDelegate = self
      } else {
        supplementaryView.text = "Other stats"
      }
    }
    
    let footerRegistration = UICollectionView.SupplementaryRegistration<FooterButtonCollectionReusableView>(elementKind: ElementKind.footer) { supplementaryView, elementKind, indexPath in
      supplementaryView.delegate = self
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
      if case let .ordinal(index) = itemIdentifier {
        return collectionView.dequeueConfiguredReusableCell(using: ordinalCellRegistration, for: indexPath, item: index)
      } else if case let .city(city) = itemIdentifier {
        return collectionView.dequeueConfiguredReusableCell(using: cityCellRegistration, for: indexPath, item: city)
      } else if case .formattedStat(_, _) = itemIdentifier {
        return collectionView.dequeueConfiguredReusableCell(using: ratioStatCellRegistration, for: indexPath, item: itemIdentifier)
      } else {
        return UICollectionViewCell()
      }
    })
    dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
      if elementKind == ElementKind.header /*|| elementKind == ElementKind.header2*/ {
        return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
      } else if elementKind == ElementKind.footer {
        return collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: indexPath)
      } else {
        fatalError("WTF")
      }
    }
    
    didChange(segmentIndex: 0)
    
    collectionView.dataSource = dataSource
  }
  
  @objc private func closeIt() {
    dismiss(animated: true)
  }
  
  private func applySnapshot() {
    // TODO: Big code changes will have to happen here to support multiple sections...
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.cityList(self.selectedSegment)])
    cities.enumerated().forEach {
      snapshot.appendItems([.ordinal($0+1), $1])
    }
    
    if let statsProvider = statsProvider {
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
    
    applySnapshot()
  }
  
  private var cities: [Item] {
    let cityList: [Item]
    switch selectedSegment {
      case .smallest:
        cityList = statsProvider?.smallestCitiesGuessed.map(Item.city) ?? []
      case .rarest:
        cityList = statsProvider?.rarestCitiesGuessed.map(Item.city) ?? []
      case .mostCommon:
        cityList = statsProvider?.commonCitiesGuessed.map(Item.city) ?? []
      case .recent:
        cityList = statsProvider?.recentCitiesGuessed.map(Item.city) ?? []
      case .largest:
        fallthrough
      default:
        cityList = statsProvider?.largestCitiesGuessed.map(Item.city) ?? []
    }
    
    return cityList.prefix(showUpTo).asArray
  }
}

extension NewGameStatsViewController: ToggleShowAllDelegate {
  func didToggle(_ showUpTo: Int) {
    self.showUpTo = showUpTo
    
    applySnapshot()
  }
}

