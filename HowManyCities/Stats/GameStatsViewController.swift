//
//  GameStatsViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit
//import Combine

final class GameStatsViewController: UIViewController {
//  private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
  
  private let viewModel: GameStatsViewModel
  
  typealias Section = GameStatsViewModel.Section
  typealias Item = GameStatsViewModel.Item
  typealias ElementKind = GameStatsViewModel.ElementKind
  
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
  
  init(statsProvider: GameStatisticsProvider) {
    viewModel = .init(statsProvider: statsProvider)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureHierarchy()
    configureDataSource()
    populateInitialData()
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
      configuration.attributedText = self.viewModel.string(for: itemIdentifier)
      configuration.directionalLayoutMargins.leading = 0
      configuration.directionalLayoutMargins.trailing = 0
      
      cell.contentConfiguration = configuration
    }
    
    let multiCityCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, [City]> { cell, indexPath, itemIdentifier in
      var configuration = UIListContentConfiguration.cell()
      configuration.attributedText = self.viewModel.string(for: itemIdentifier)
      configuration.directionalLayoutMargins.leading = 0
      configuration.directionalLayoutMargins.trailing = 0
      cell.contentConfiguration = configuration
    }
    
    let stateCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, itemIdentifier in
      guard case let .state(stateName, cities) = itemIdentifier else {
        return
      }
      var configuration = UIListContentConfiguration.cell()
      configuration.attributedText = self.viewModel.string(for: stateName, cities)
      
      cell.contentConfiguration = configuration
    }
    
    let ratioStatCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, itemIdentifier in
      guard case let .formattedStat(ratio, description) = itemIdentifier else { return }
      var configuration = UIListContentConfiguration.cell()
      configuration.attributedText = self.viewModel.string(for: ratio, description)
    
      cell.contentConfiguration = configuration
    }
    
    let emptyStateCellRegistration = UICollectionView.CellRegistration<EmptyStateCollectionViewCell, Section> { cell, indexPath, itemIdentifier in
      var configuration = UIListContentConfiguration.cell()
      configuration.textProperties.color = .systemGray
      configuration.textProperties.font = .italicSystemFont(ofSize: UIFont.labelFontSize)
      
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
      supplementaryView.title = section.description
      
      switch section {
        case .cityList:
          // TODO: And we could reduce most/least populated into 1 segment, same with popular/rarest, and then in the third tab
          // can sort alphabetically, alphabetically by country, recently, or...
          // MAYBE JUST HAVE 1 CATEGORY WITH DIFFERENT SORTT OPTIONS?? LIKE F*CK THE SEGMENT
          supplementaryView.subtitle = self.viewModel.citySortMode.description
          supplementaryView.configure(sortCb: self.didTapSortCities)
        case .stateList, .territoryList:
          supplementaryView.subtitle = self.viewModel.stateSortMode.description
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
          guard (self.viewModel.statsProvider?.recentCitiesGuessed.count ?? 0) > 10 else {
            supplementaryView.isHidden = true
            return
          }
          
          supplementaryView.configure(isShowingAll: self.viewModel.showCitiesUpTo == Int.max) { isShowingAll in
            self.viewModel.showCitiesUpTo = isShowingAll ? Int.max : 10
          }
        case .stateList:
          supplementaryView.isHidden = self.viewModel.statsProvider?.citiesByCountry.count ?? 0 <= 10
          supplementaryView.configure(isShowingAll: self.viewModel.showStatesUpTo == Int.max) { isShowingAll in
            self.viewModel.showStatesUpTo = isShowingAll ? Int.max : 10
          }
        case .territoryList:
          supplementaryView.isHidden = self.viewModel.statsProvider?.citiesByTerritory.count ?? 0 <= 10
          supplementaryView.configure(isShowingAll: self.viewModel.showTerritoriesUpTo == Int.max) { isShowingAll in
            self.viewModel.showTerritoriesUpTo = isShowingAll ? Int.max : 10
          }
        case .otherStats:
          break
      }
    }
    
    let textFooterRegistration = UICollectionView.SupplementaryRegistration<FooterTextCollectionReusableView>(elementKind: ElementKind.textFooter) { supplementaryView, elementKind, indexPath in
      supplementaryView.configure(text: "Save your results to see what you missed.")
      supplementaryView.backgroundColor = .systemBackground
    }
    
    viewModel.dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
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
    }
    viewModel.dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
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
    
    collectionView.dataSource = viewModel.dataSource
  }
  
  @objc private func closeIt() {
    dismiss(animated: true)
  }
  
  private func populateInitialData() {
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.cityList, .stateList, .territoryList, .otherStats])
    
    viewModel.refreshCityList(&snapshot)
    viewModel.refreshStateList(&snapshot)
    viewModel.refreshTerritoryList(&snapshot)
    viewModel.refreshOtherStats(&snapshot)
    
    viewModel.dataSource.apply(snapshot, animatingDifferences: true)
  }
}


extension GameStatsViewController: UICollectionViewDelegate {
  private func toggleHighlight(_ isOn: Bool, collectionView: UICollectionView, at indexPath: IndexPath) {
    let color: UIColor = isOn ? .systemFill : .clear
    guard let section = Section(rawValue: indexPath.section) else { return }
    let items = viewModel.dataSource.snapshot().itemIdentifiers(inSection: section)
    
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
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let section = Section(rawValue: indexPath.section) else { return }
    let items = viewModel.dataSource.snapshot().itemIdentifiers(inSection: section)
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
    cityVC.statsProvider = viewModel.statsProvider
    cityVC.city = city

    navigationController?.pushViewController(cityVC)
  }
  
  private func showStateVC(_ state: State, cities: [City]) {
    let stateVC = StateInfoViewController(state: state, guessedCities: cities)
    
    navigationController?.pushViewController(stateVC)
  }
}

extension GameStatsViewController {
  func didTapSortCities() {
    viewModel.citySortMode = viewModel.citySortMode.nextMode
    
    // TODO: Lmao this is so fucking illegal
    guard let titleHeader = collectionView.supplementaryView(forElementKind: ElementKind.header, at: .init(row: 0, section: Section.cityList.rawValue)) as? CollectionViewHeaderReusableView else { return }
    titleHeader.subtitle = viewModel.citySortMode.description
  }
  
  func didTapSortStates() {
    viewModel.stateSortMode = viewModel.stateSortMode.nextMode
    // TODO: Lmao this is so fucking illegal
    guard let titleHeader = collectionView.supplementaryView(forElementKind: ElementKind.header, at: .init(row: 0, section: Section.stateList.rawValue)) as? CollectionViewHeaderReusableView else { return }
    titleHeader.subtitle = viewModel.stateSortMode.description
    
    // TODO: Lmao this is so fucking illegal
    guard let titleHeader2 = collectionView.supplementaryView(forElementKind: ElementKind.header, at: .init(row: 0, section: Section.territoryList.rawValue)) as? CollectionViewHeaderReusableView else { return }
    titleHeader2.subtitle = viewModel.stateSortMode.description
  }
}

