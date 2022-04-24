//
//  StateSelectorViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/11/22.
//

import UIKit

protocol StateSearchDelegate: AnyObject {
  var topLevelStates: [State] { get }
  var lowerDivisionStates: [State] { get }
}


final class StateSearchController: UIViewController {
  
  private var specialSectionLabels: [GuessMode] = [.any, .every]
  
  private var presentedStates: [State] {
//    guard let searchText = searchBar.text,
    let scopeIndex = searchController.searchBar.selectedScopeButtonIndex
    guard let searchText = searchController.searchBar.text,
          !searchText.isEmpty else {
      if scopeIndex == 0 {
        return statesDelegate?.topLevelStates ?? []
      } else {
        return statesDelegate?.lowerDivisionStates ?? []
      }
    }
    
    if scopeIndex == 0 {
      return statesDelegate?.topLevelStates.filter { $0.name.lowercased().contains(searchText.lowercased()) } ?? []
    } else {
      return statesDelegate?.lowerDivisionStates.filter { $0.name.lowercased().contains(searchText.lowercased()) } ?? []
    }
  }
  
  private func statesStartingWith(_ letter: Character) -> [State] {
    presentedStates.filter { $0.name.starts(with: String(letter)) }
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
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.autocapitalizationType = .words
    searchController.searchBar.placeholder = "Search for a country"
    searchController.searchBar.scopeButtonTitles = ["Countries", "States"]
    searchController.searchBar.showsScopeBar = true
    searchController.searchBar.delegate = self
    
    return searchController
  }()
  
  private lazy var doneButton: UIButton = {
    // TODO: This may not be the right style...
    let button = UIButton(type: .system).autolayoutEnabled
    button.setTitle("Done", for: .normal)
    button.titleLabel?.numberOfLines = 1
    button.setTitleColor(.systemBlue, for: .normal)
    button.contentHorizontalAlignment = .center
    button.addTarget(self, action: #selector(didSelectState), for: .touchUpInside)
    
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
  
  weak var statesDelegate: StateSearchDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    
    view.addSubview(tableView)
    view.addSubview(doneButton)
    
    title = "Pick a country"
    navigationItem.title = "Pick a country"
    navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(didSelectState)) // TODO: impl
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
    
    searchController.searchBar.becomeFirstResponder()
  }
  
  @objc private func didSelectState() {
    // TODO: impl
    dismiss(animated: true)
  }
  
  @objc private func didCloseSelector() {
    dismiss(animated: true)
  }
}

extension StateSearchController: UITableViewDelegate, UITableViewDataSource {
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
    return statesStartingWith(letter).count
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
    let statesWithLetter = statesStartingWith(letter)
    
    let stateName = statesWithLetter[indexPath.row].name
    cell.textLabel?.text = GuessMode.specific(stateName).fullDisplayName
    
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

extension StateSearchController: UISearchBarDelegate {
//  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//    tableView.reloadData()
//  }
//
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    // TODO: do this
    let term = selectedScope == 0 ? "country" : "state"
    searchBar.placeholder = "Search for a \(term)"
    title = "Pick a \(term)"
    navigationItem.title = "Pick a \(term)"
  }
}

extension StateSearchController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    tableView.reloadData()
  }
}

extension StateSearchController: UISearchControllerDelegate {
  
}
