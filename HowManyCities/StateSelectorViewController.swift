//
//  StateSelectorViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/11/22.
//

import UIKit

protocol StatesDataSource: AnyObject {
  var topLevelStates: [State] { get }
  var lowerDivisionStates: [State] { get }
}

protocol GuessModeDelegate: AnyObject {
  func didChangeGuessMode(_ mode: GuessMode)
}


final class StateSearchController: UIViewController {
  
  private var specialModes: [GuessMode] = [.any, .every]
  
  private var normalizedSearchText: String? {
    searchController.searchBar.text?.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
  }
  
  private var presentedTopLevelStates: [State] {
    guard let searchText = normalizedSearchText,
          !searchText.isEmpty else {
      return statesDataSource?.topLevelStates ?? []
    }
  
    return statesDataSource?.topLevelStates.filter {
      let countryNameNormalized = $0.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
      return countryNameNormalized.contains(searchText)
    } ?? []
  }
  
  private func topLevelStatesStartingWith(_ letter: Character) -> [State] {
    presentedTopLevelStates.filter { $0.name.starts(with: String(letter)) }
  }
  
  private func presentedLowerDivisionStates(for state: State) -> [State] {
    guard let searchText = normalizedSearchText,
          !searchText.isEmpty else {
      return state.states ?? []
    }
    
    return state.states?.filter {
      let countryNameNormalized = $0.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
      return countryNameNormalized.contains(searchText)
    } ?? []
  }
  
  private var selectedMode: GuessMode {
    didSet {
      guessModeDelegate?.didChangeGuessMode(selectedMode)
    }
  }
  
  private lazy var searchController: UISearchController = {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.autocapitalizationType = .words
    searchController.searchBar.placeholder = "Search for a location"
    searchController.hidesNavigationBarDuringPresentation = false
    
    return searchController
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.allowsSelection = true
    tableView.allowsMultipleSelection = false
    tableView.backgroundColor = .systemBackground

    return tableView
  }()
  
  weak var statesDataSource: StatesDataSource?
  
  weak var guessModeDelegate: GuessModeDelegate?
  
  init(selectedMode: GuessMode) {
    self.selectedMode = selectedMode
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    
    view.addSubview(tableView)
    
    title = "Pick a location"
    navigationItem.title = "Pick a location"
    navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(didCloseSelector))
    
    view.backgroundColor = .systemBackground
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(StateTableViewCell.self, forCellReuseIdentifier: StateTableViewCell.identifier)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.async { [weak self] in
      self?.searchController.searchBar.becomeFirstResponder()
    }
  }
  
  @objc private func didCloseSelector() {
    searchController.searchBar.resignFirstResponder()
    resignFirstResponder()
    DispatchQueue.main.async {
      self.dismiss(animated: true)
    }
  }
}

extension StateSearchController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    // 1 special section at the top
    // 26 sections for countries ordered by name
    // remaining sections for states, provinces, and territories by (eligible) country
    1 + 26 + (statesDataSource?.lowerDivisionStates.count ?? 0) // TODO: Update this based on search results
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section >= 26 + 1,
       (tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section) ?? 0) > 0 {
      return statesDataSource?.lowerDivisionStates[section - (26+1)].name
    } else {
      return nil
    }
  }
  
  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    "🌎ABCDEFGHIJKLMNOPQRSTUVWXYZ🗺".map(String.init)
  }
      
  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
      index
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return specialModes.count
    }
    
    if 1 <= section && section <= 26 {
      let letter = Character(UnicodeScalar(65+(section-1))!)
      return topLevelStatesStartingWith(letter).count
    }
    
    else {
      // this is states, territories, and provinces
      guard let parentState = statesDataSource?.lowerDivisionStates[section-(26+1)] else { return 0 }
      return presentedLowerDivisionStates(for: parentState).count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: StateTableViewCell.identifier, for: indexPath) as? StateTableViewCell else {
      return UITableViewCell()
    }
    cell.selectionStyle = .none
    cell.indentationLevel = 0
    
    let letter = Character(UnicodeScalar(65+(indexPath.section-1))!)
    
    if indexPath.section == 0 {
      cell.associatedMode = specialModes[indexPath.row]
    }
    
    else if 1 <= indexPath.section && indexPath.section <= 26 {
      // countries organized by first letter
      let statesWithLetter = topLevelStatesStartingWith(letter)
      
      let state = statesWithLetter[indexPath.row]
      let guessMode = GuessMode.specific(state)
      cell.associatedMode = guessMode
    }
    
    else if indexPath.section >= 1+26 {
      // states, provinces, and territories
      guard var parentState = statesDataSource?.lowerDivisionStates[indexPath.section-(1+26)] else { return cell }
      let childStates = presentedLowerDivisionStates(for: parentState)
      parentState.states = [childStates[indexPath.row]]
      let guessMode = GuessMode.specific(parentState)
      cell.associatedMode = guessMode
      cell.indentationLevel = 1
    }
    
    if cell.associatedMode == selectedMode {
      cell.accessoryType = .checkmark
      DispatchQueue.main.async {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
      }
    } else {
      cell.accessoryType = .none
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let stateCell = tableView.cellForRow(at: indexPath) as? StateTableViewCell else { return }
    stateCell.accessoryType = .checkmark
    selectedMode = stateCell.associatedMode
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .none
  }
}

extension StateSearchController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    tableView.reloadData()
  }
}

extension StateSearchController: UISearchControllerDelegate {
  
}

final class StateTableViewCell: UITableViewCell {
  static let identifier = "StateTableViewCell"
  
  var associatedMode: GuessMode = .any {
    didSet {
      textLabel?.text = associatedMode.fullDisplayName
    }
  }
}
