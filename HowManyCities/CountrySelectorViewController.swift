//
//  CountrySelectorViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/11/22.
//

import UIKit

protocol CountrySearchDelegate: AnyObject {
  var countries: [State] { get }
}


final class CountrySearchController: UIViewController {
  
  private var specialSectionLabels: [GuessMode] = [.any, .every]
  
  private var countriesPostSearch: [State] {
//    guard let searchText = searchBar.text,
    guard let searchText = searchController.searchBar.text,
          !searchText.isEmpty else { return countryDelegate?.countries ?? [] }
    
    return countryDelegate?.countries.filter { $0.name.lowercased().contains(searchText.lowercased()) } ?? []
  }
  
  private func countriesStartingWith(_ letter: Character) -> [State] {
    countriesPostSearch.filter { $0.name.starts(with: String(letter)) }
  }
  
//  private lazy var searchBar: UISearchBar = {
//    let bar = UISearchBar().autolayoutEnabled
//    bar.autocapitalizationType = .words
//    bar.delegate = self
//
//
//    return bar
//  }()
  
  private lazy var searchController: UISearchController = {
    let ctrl = UISearchController(searchResultsController: nil)
    ctrl.searchResultsUpdater = self
    ctrl.obscuresBackgroundDuringPresentation = false
    ctrl.searchBar.placeholder = "Search for a country"
    
    return ctrl
  }()
  
  private lazy var doneButton: UIButton = {
    // TODO: This may not be the right style...
    let button = UIButton(type: .system).autolayoutEnabled
    button.setTitle("Done", for: .normal)
    button.titleLabel?.numberOfLines = 1
    button.setTitleColor(.systemBlue, for: .normal)
    button.contentHorizontalAlignment = .center
    button.addTarget(self, action: #selector(didSelectCountry), for: .touchUpInside)
    
    return button
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.allowsSelection = true
    tableView.allowsMultipleSelection = false
    tableView.backgroundColor = .systemBackground

    return tableView
  }()
  
  weak var countryDelegate: CountrySearchDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    
    view.addSubview(tableView)
    view.addSubview(doneButton)
    
    title = "Pick a country"
    navigationItem.title = "Pick a country"
    navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(didSelectCountry)) // TODO: impl
    navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(didCloseSelector))
    
//    definesPresentationContext = true
    
    view.backgroundColor = .systemBackground
//    view.addSubview(searchBar)
    
    NSLayoutConstraint.activate([
//      searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//      searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//      searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//
//      tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor),
      
      doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  @objc private func didSelectCountry() {
    // TODO: impl
    dismiss(animated: true)
  }
  
  @objc private func didCloseSelector() {
    dismiss(animated: true)
  }
}

extension CountrySearchController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    // 1 special section at the top
    1 + 26 // TODO: Update this based on search results
  }
  
  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    "*ABCDEFGHIJKLMNOPQRSTUVWXYZ".map(String.init)
  }
      
  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
      index
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return specialSectionLabels.count
    }
    
    let letter = Character(UnicodeScalar(65+(section-1))!)
    return countriesStartingWith(letter).count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.selectionStyle = .none
    
    if indexPath == tableView.indexPathForSelectedRow {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    
    if indexPath.section == 0 {
      cell.textLabel?.text = specialSectionLabels[indexPath.row].fullDisplayName
      return cell
    }
    
    let letter = Character(UnicodeScalar(65+(indexPath.section-1))!)
    let countriesWithLetter = countriesStartingWith(letter)
    
    let countryName = countriesWithLetter[indexPath.row].name
    cell.textLabel?.text = GuessMode.specific(countryName).fullDisplayName
    
    return cell
  }
  
//  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//    if let oldIndex = tableView.indexPathForSelectedRow {
//      tableView.cellForRow(at: oldIndex)?.accessoryType = .none
//      tableView.reloadRows(at: [indexPath, oldIndex], with: .none)
//    } else {
//      tableView.reloadRows(at: [indexPath], with: .none)
//    }
//
//
//    return indexPath
//  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .none
  }
}

//extension CountrySearchController: UISearchBarDelegate {
//  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//    tableView.reloadData()
//  }
//}

extension CountrySearchController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    tableView.reloadData()
  }
}
