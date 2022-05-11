//
//  CityListViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/11/22.
//

import UIKit

final class CityListViewController: UITableViewController {
  private let cities: [City]
  
  private var dataSource: UITableViewDiffableDataSource<Int, City>!
  
  private weak var presentingVC: UIViewController?
  
  init(cities: [City]) {
    self.cities = cities
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    dataSource = .init(tableView: tableView) { tableView, indexPath, itemIdentifier in
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      var config = UIListContentConfiguration.cell()
      
      if let flag = itemIdentifier.countryFlag {
        config.attributedText = .init(string: "\(flag) \(itemIdentifier.nameWithStateAbbr)")
      } else {
        config.attributedText = .init(string: itemIdentifier.nameWithStateAbbr)
      }
      cell.contentConfiguration = config
      
      return cell
    }
    
    tableView.delegate = self
    tableView.dataSource = dataSource
    
//    view.translatesAutoresizingMaskIntoConstraints = false
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
//    view.addSubview(tableView)
    // WTF????
    tableView.pin(to: view.safeAreaLayoutGuide)
    
    var snapshot = dataSource.snapshot()
    // TODO: Maybe organize by country A->Z the sections?????
    snapshot.appendSections([0])
    snapshot.appendItems(cities)
    
    dataSource.apply(snapshot)
  }
  
  override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)
    
    presentingVC = parent
    
    guard let parent = parent as? UIAlertController else {
      return
    }

    view.pin(to: parent.view, margins: .init(top: 60, left: 0, bottom: 44, right: 0)) // TODO: Lmao this is so fucking illegal
    
    parent.view.clipsToBounds = true
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let items = dataSource.snapshot().itemIdentifiers(inSection: indexPath.section)
    let item = items[indexPath.row]
    
    let cityVC = CityInfoViewController()
    cityVC.city = item
    
    (presentingVC ?? self).navigationController?.present(cityVC, animated: true)
    
  }
}
