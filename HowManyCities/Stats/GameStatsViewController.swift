//
//  GameStatsViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/27/22.
//

import UIKit

final class GameStatsViewController: UIViewController {
  var statsDelegate: GameStatisticsDelegate?
  
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
    cv.dataSource = self
    cv.register(HeaderAndListCollectionViewCell.self, forCellWithReuseIdentifier: HeaderAndListCollectionViewCell.identifier)
    cv.register(ChartCollectionViewCell.self, forCellWithReuseIdentifier: ChartCollectionViewCell.identifier)
    
    cv.register(TitleCollectionReusableView.self, forSupplementaryViewOfKind: "title-element-kind", withReuseIdentifier: "TitleCollectionReusableView")
    return cv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    title = "Statistics"
    navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(closeIt))
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(collectionView)
    collectionView.pin(to: view.safeAreaLayoutGuide)
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

extension GameStatsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    2
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 { return 3 }
    if section == 1 { return 1 }
    
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if indexPath.section == 1 {
      guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: "title-element-kind", withReuseIdentifier: "TitleCollectionReusableView", for: indexPath) as? TitleCollectionReusableView else {
        return .init()
      }
      view.text = "Best countries"
      
      return view
    } else {
      return .init()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.section == 0 {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderAndListCollectionViewCell.identifier, for: indexPath) as? HeaderAndListCollectionViewCell else {
        return UICollectionViewCell()
      }
      
      cell.layer.borderWidth = 1.0
      cell.layer.borderColor = UIColor.systemFill.cgColor
      cell.layer.cornerRadius = 12.0
      cell.clipsToBounds = true
      
      let cityPopulationRenderer = CityPopulationRenderer()
      let cityRarityRenderer = CityRarityRenderer()
      
      if indexPath.row == 0 {
        cell.configure(header: "Biggest cities", items: statsDelegate?.largestCitiesGuessed, renderer: cityPopulationRenderer)
      } else if indexPath.row == 1 {
        cell.configure(header: "Smallest cities YOU FUCKING AUTOLAYOUT PIECE OF SHIT", items: statsDelegate?.smallestCitiesGuessed, renderer: cityPopulationRenderer)
      } else if indexPath.row == 2 {
        cell.configure(header: "Rarest guessed", items: statsDelegate?.rarestCitiesGuessed, renderer: cityRarityRenderer)
      }
      
      return cell
    } else if indexPath.section == 1 {
      guard let statsDelegate = statsDelegate,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartCollectionViewCell.identifier, for: indexPath) as? ChartCollectionViewCell else {
        return UICollectionViewCell()
      }
      
      cell.setData(statsDelegate.citiesByCountry)
      return cell
    } else {
      return UICollectionViewCell()
    }
  }
  
  
}
