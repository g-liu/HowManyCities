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
    let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
    item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(0.5)), subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 8.0
    section.orthogonalScrollingBehavior = .groupPaging
    section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout).autolayoutEnabled
    cv.delegate = self
    cv.dataSource = self
//    cv.contentSize = UICollectionView.automat
    cv.register(HeaderAndListCollectionViewCell.self, forCellWithReuseIdentifier: HeaderAndListCollectionViewCell.identifier)
    return cv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    title = "Statistics"
    navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(closeIt))
    
    view.backgroundColor = .systemBackground
    
//    guard let statsDelegate = statsDelegate else {
//      return
//    }
    
    view.addSubview(collectionView)
    collectionView.pin(to: view.safeAreaLayoutGuide)
    
//    let stackView = UIStackView().autolayoutEnabled
//    stackView.axis = .vertical
//
//    stackView.addArrangedSubview(createLabel(text: "Cities guessed: \(statsDelegate.numCitiesGuessed)"))
//
//    stackView.addArrangedSubview(createLabel(text: "***BIGGEST CITIES***"))
//    statsDelegate.largestCitiesGuessed.forEach {
//      let label = createLabel(text: "\($0.fullTitle) - \($0.population.commaSeparated)")
//      stackView.addArrangedSubview(label)
//    }
//
//    stackView.addArrangedSubview(createLabel(text: "**** BEST COUNTRIES ****"))
//    statsDelegate.citiesByCountry.sorted { $0.value.count > $1.value.count }.forEach {
//      let label = createLabel(text: "\($0.key): \($0.value.count) (pop: \($0.value.totalPopulation.commaSeparated))")
//      stackView.addArrangedSubview(label)
//    }
//
//    view.addSubview(stackView)
//    stackView.pin(to: view.safeAreaLayoutGuide)
  }
  
  private func createLabel(text: String) -> UILabel {
    let label = UILabel().autolayoutEnabled
    label.text = text
    return label
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
  @objc private func closeIt() {
    dismiss(animated: true)
  }
  
}

extension GameStatsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    3
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderAndListCollectionViewCell.identifier, for: indexPath) as? HeaderAndListCollectionViewCell else {
      return UICollectionViewCell()
    }
    
    cell.configure(header: "Biggest cities")
    cell.layer.borderWidth = 1.0
    cell.layer.borderColor = UIColor.systemFill.cgColor
    cell.layer.cornerRadius = 12.0
    
    return cell
  }
  
  
}
