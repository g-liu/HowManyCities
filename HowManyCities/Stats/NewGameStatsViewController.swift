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
    static let segmentedControl = "element-kind-segmented-control"
  }
  
  enum Section: Int {
    case cityList
    case citiesByCountry
  }
  
  enum Item: Hashable {
    case ordinal(Int)
    case city(City)
    
    case citiesByState([String: [City]])
    case formattedStat(Int, Int, String)
  }
  
  var statsProvider: GameStatisticsProvider?
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  
  private lazy var collectionView: UICollectionView = {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { (sectionIndex, environment) -> NSCollectionLayoutSection? in
      // TODO: This is the first section only; need per-section layout eventually...
      
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
      
      let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.header, alignment: .top)
      sectionHeader.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
      section.boundarySupplementaryItems = [sectionHeader]
      section.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
      
      return section
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
    
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, City> { cell, indexPath, itemIdentifier in
      // TODO: THE RENDERER MUST DEPEND ON THE SELECTED SEGMENT!!!!!!!!
//      cell.configure(item: itemIdentifier, renderer: CityPopulationRenderer())
      var configuration = UIListContentConfiguration.cell()
      configuration.attributedText = CityPopulationRenderer().string(itemIdentifier)
      configuration.directionalLayoutMargins = .zero
      
      cell.contentConfiguration = configuration
      cell.contentView.layoutMargins = .zero
    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<TitleCollectionReusableView>(elementKind: ElementKind.header) { supplementaryView, elementKind, indexPath in
      supplementaryView.text = "Top cities"
      // TODO: Persist selection
      supplementaryView.configure(segmentTitles: ["Biggest", "Smallest", "Rarest", "Recent"])
      supplementaryView.segmentChangeDelegate = self
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
      if case let .ordinal(index) = itemIdentifier {
        return collectionView.dequeueConfiguredReusableCell(using: ordinalCellRegistration, for: indexPath, item: index)
      } else if case let .city(city) = itemIdentifier {
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: city)
      } else {
        return UICollectionViewCell()
      }
    })
    dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    }
    
    // Initial data
    // TODO: APPLY THIS
//    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
//    snapshot.appendSections([.cityList])
//    cities().enumerated().forEach {
//      snapshot.appendItems([.ordinal($0+1), $1])
//    }
//    dataSource.apply(snapshot)
    didChange(segmentIndex: 0)
    
    collectionView.dataSource = dataSource
  }
  
  @objc private func closeIt() {
    dismiss(animated: true)
  }
}


extension NewGameStatsViewController: UICollectionViewDelegate {
  
}


extension NewGameStatsViewController: SegmentChangeDelegate {
  func didChange(segmentIndex: Int) {
    // TODO: Big code changes will have to happen here to support multiple sections...
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.cityList])
    cities(for: segmentIndex).enumerated().forEach {
      snapshot.appendItems([.ordinal($0+1), $1])
    }
    dataSource.apply(snapshot)
  }
  
  private func cities(for segmentIndex: Int = 0) -> [Item] {
    let cityList: [Item]
    switch segmentIndex {
      case 1:
        cityList = statsProvider?.smallestCitiesGuessed.map(Item.city) ?? []
      case 2:
        cityList = statsProvider?.rarestCitiesGuessed.map(Item.city) ?? []
      case 3:
        cityList = statsProvider?.recentCitiesGuessed.map(Item.city) ?? []
      case 0:
        fallthrough
      default:
        cityList = statsProvider?.largestCitiesGuessed.map(Item.city) ?? []
    }
    
    return cityList.prefix(10).asArray
  }
}
