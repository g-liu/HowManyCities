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
    case city(Int, City)
    case citiesByState([String: [City]])
    case formattedStat(Int, Int, String)
  }
  
  var statsProvider: GameStatisticsProvider?
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  
  private lazy var collectionView: UICollectionView = {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { (sectionIndex, environment) -> NSCollectionLayoutSection? in
      // TODO: This is the first section only; need per-section layout eventually...
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
      let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      
      let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.header, alignment: .top)
      section.boundarySupplementaryItems = [sectionHeader]
      
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
    let cellRegistration = UICollectionView.CellRegistration<NumberedListCollectionViewCell, City> { cell, indexPath, itemIdentifier in
      cell.configure(order: indexPath.row, item: itemIdentifier, renderer: CityPopulationRenderer())
    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<TitleCollectionReusableView>(elementKind: ElementKind.header) { supplementaryView, elementKind, indexPath in
      supplementaryView.text = "Top cities"
      // TODO: Persist selection
      supplementaryView.configure(segmentTitles: ["Biggest", "Smallest", "Rarest", "Recent"])
      supplementaryView.segmentChangeDelegate = self
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
      if case let .city(index, city) = itemIdentifier {
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: city)
      } else {
        return UICollectionViewCell()
      }
    })
    dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    }
    
    // Initial data
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.cityList])
    snapshot.appendItems(cities())
    dataSource.apply(snapshot)
    
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
    snapshot.appendItems(cities(for: segmentIndex))
    dataSource.apply(snapshot)
  }
  
  private func cities(for segmentIndex: Int = 0) -> [Item] {
    let cityList: [Item]
    switch segmentIndex {
      case 1:
        cityList = statsProvider?.smallestCitiesGuessed.enumerated().map(Item.city) ?? []
      case 2:
        cityList = statsProvider?.rarestCitiesGuessed.enumerated().map(Item.city) ?? []
      case 3:
        cityList = statsProvider?.recentCitiesGuessed.enumerated().map(Item.city) ?? []
      case 0:
        fallthrough
      default:
        cityList = statsProvider?.largestCitiesGuessed.enumerated().map(Item.city) ?? []
    }
    
    return cityList.prefix(10).asArray
  }
}
