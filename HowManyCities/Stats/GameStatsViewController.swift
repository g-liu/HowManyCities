//
//  GameStatsViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/27/22.
//

import UIKit
import Charts

final class GameStatsViewController: UIViewController {
  enum Section: Int {
    case superlatives
    case citiesByCountry
  }
  
  // TODO: How is this gonna play out with the pie chart? LOL
  struct Item: Hashable, Equatable {
    let title: String
    let items: [City]? // TODO: Genericize... maybe?????
  }
  
  var statsDelegate: GameStatisticsProvider?
  
  var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
  
  private lazy var collectionView: UICollectionView = {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { (sectionIndex, environment) -> NSCollectionLayoutSection? in
      if sectionIndex == 0 {
        let heightDim = NSCollectionLayoutDimension.estimated(10)
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: heightDim))
        //        item.edgeSpacing = .init(leading: .flexible(2.0), top: .flexible(2.0), trailing: .flexible(2.0), bottom: .flexible(2.0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: heightDim), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8.0
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
      } else if sectionIndex == 1 {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.8)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44)),
          elementKind: "title-element-kind",
          alignment: .top)
        section.boundarySupplementaryItems = [titleSupplementary]
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        return section
      } else {
        return nil
      }
    }
    
    let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout).autolayoutEnabled
    cv.delegate = self
//    cv.dataSource = self // TODO: Replace with diffable datasource
    cv.register(HeaderAndListCollectionViewCell.self, forCellWithReuseIdentifier: HeaderAndListCollectionViewCell.identifier)
    cv.register(ChartCollectionViewCell.self, forCellWithReuseIdentifier: ChartCollectionViewCell.identifier)
    
    cv.register(CollectionViewHeaderReusableView.self, forSupplementaryViewOfKind: "title-element-kind", withReuseIdentifier: "CollectionViewHeaderReusableView")
    return cv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Statistics"
    navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(closeIt))
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(collectionView)
    collectionView.pin(to: view.safeAreaLayoutGuide)
    
    let headerAndListCellRegistration = createHeaderAndListCellRegistration()
    let pieChartCellRegistration = createPieChartCellRegistration().self
    
    let headerRegistration = createHeaderRegistration()
    
    dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
      guard let section = Section(rawValue: indexPath.section) else {
        fatalError("WTF?")
      }
      switch section {
        case .superlatives:
          return collectionView.dequeueConfiguredReusableCell(using: headerAndListCellRegistration, for: indexPath, item: item)
        case .citiesByCountry:
          return collectionView.dequeueConfiguredReusableCell(using: pieChartCellRegistration, for: indexPath, item: item)
      }
    })
    
    dataSource.supplementaryViewProvider = .some({ collectionView, elementKind, indexPath in
      self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    })
    collectionView.dataSource = dataSource
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.superlatives])
    snapshot.appendItems([.init(title: "Biggest cities", items: statsDelegate?.largestCitiesGuessed),
                          .init(title: "Smallest cities", items: statsDelegate?.smallestCitiesGuessed),
                          .init(title: "Rarest guessed", items: statsDelegate?.rarestCitiesGuessed)])
    dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func createLabel(text: String) -> UILabel {
    let label = UILabel().autolayoutEnabled
    label.text = text
    return label
  }
  
  @objc private func closeIt() {
    dismiss(animated: true)
  }
}

// MARK: - Cell registrations
extension GameStatsViewController {
  func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<CollectionViewHeaderReusableView> {
    .init(elementKind: "title-element-kind") { supplementaryView, elementKind, indexPath in
      supplementaryView.text = "IDK???"
    }
  }
  
  func createHeaderAndListCellRegistration() -> UICollectionView.CellRegistration<HeaderAndListCollectionViewCell, Item /* TODO: IDK???? */> {
    .init { cell, indexPath, item in
      cell.layer.borderWidth = 1.0
      cell.layer.borderColor = UIColor.systemFill.cgColor
      cell.layer.cornerRadius = 12.0
      cell.clipsToBounds = true
      
      let cityPopulationRenderer = CityPopulationRenderer()
      let cityRarityRenderer = CityRarityRenderer()
      
      // TODO: Insert actual data in `items`
      if indexPath.row == 0 {
        cell.configure(header: "Biggest cities", items: item.items, renderer: cityPopulationRenderer)
      } else if indexPath.row == 1 {
        cell.configure(header: "Smallest cities", items: item.items, renderer: cityPopulationRenderer)
      } else if indexPath.row == 2 {
        cell.configure(header: "Rarest guessed", items: item.items, renderer: cityRarityRenderer)
      }
    }
  }
  
  func createPieChartCellRegistration() -> UICollectionView.CellRegistration<ChartCollectionViewCell, Item> {
    .init { cell, indexPath, item in
      // TODO: Stuff
    }
  }
}

// MARK: - Delegate
extension GameStatsViewController: UICollectionViewDelegate {
  
}

// TODO: TEMP PLZ RMV
extension GameStatsViewController: WhateverDelegate {
  func didToggleList() {
//    collectionView.collectionViewLayout.invalidateLayout()
    // TODO: WHAT PUT HERE
  }
}
