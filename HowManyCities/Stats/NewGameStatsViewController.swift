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
  }
  
  enum Section: Int {
    case cityList
    case citiesByCountry
  }
  
  enum Item: Hashable {
    case city(City)
    case citiesByState([String: [City]])
    case formattedStat(Int, Int, String)
  }
  
  var statsProvider: GameStatisticsProvider?
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  
  private lazy var collectionView: UICollectionView = {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { (sectionIndex, environment) -> NSCollectionLayoutSection? in
      // TODO: This is the first section only; need per-section layout eventually...
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
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
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, City> { cell, indexPath, itemIdentifier in
      // TODO: Create custom cell
      var config = UIListContentConfiguration.cell()
      config.text = "\(indexPath.row): \(itemIdentifier.fullTitle)"
      
      cell.contentConfiguration = config
    }
    
    let headerRegistration = UICollectionView.SupplementaryRegistration<TitleCollectionReusableView>(elementKind: ElementKind.header) { supplementaryView, elementKind, indexPath in
      supplementaryView.text = "Top cities"
    }
    
    dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
      if case let .city(city) = itemIdentifier {
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
    snapshot.appendItems(statsProvider?.largestCitiesGuessed.map(Item.city) ?? [])
    dataSource.apply(snapshot)
    
    collectionView.dataSource = dataSource
  }
  
  @objc private func closeIt() {
    dismiss(animated: true)
  }
}


extension NewGameStatsViewController: UICollectionViewDelegate {
  
}
