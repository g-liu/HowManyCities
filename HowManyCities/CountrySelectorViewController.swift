//
//  CountrySelectorViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/11/22.
//

import UIKit

final class CountrySelector: UIPickerView {
  // Fuck it
}


final class CountrySearchController: UIViewController {
  private let countries = ["Afghanistan","Albania","Algeria","Andorra","Angola","Antigua & Deps","Argentina","Armenia","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bhutan","Bolivia","Bosnia Herzegovina","Botswana","Brazil","Brunei","Bulgaria","Burkina","Burundi","Cambodia","Cameroon","Canada","Cape Verde","Central African Rep","Chad","Chile","China","Colombia","Comoros","Congo","Congo {Democratic Rep}","Costa Rica","Croatia","Cuba","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","East Timor","Ecuador","Egypt","El Salvador","Equatorial Guinea","Eritrea","Estonia","Ethiopia","Fiji","Finland","France","Gabon","Gambia","Georgia","Germany","Ghana","Greece","Grenada","Guatemala","Guinea","Guinea-Bissau","Guyana","Haiti","Honduras","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland {Republic}","Israel","Italy","Ivory Coast","Jamaica","Japan","Jordan","Kazakhstan","Kenya","Kiribati","Korea North","Korea South","Kosovo","Kuwait","Kyrgyzstan","Laos","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macedonia","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Marshall Islands","Mauritania","Mauritius","Mexico","Micronesia","Moldova","Monaco","Mongolia","Montenegro","Morocco","Mozambique","Myanmar, {Burma}","Namibia","Nauru","Nepal","Netherlands","New Zealand","Nicaragua","Niger","Nigeria","Norway","Oman","Pakistan","Palau","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal","Qatar","Romania","Russian Federation","Rwanda","St Kitts & Nevis","St Lucia","Saint Vincent & the Grenadines","Samoa","San Marino","Sao Tome & Principe","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia","Solomon Islands","Somalia","South Africa","South Sudan","Spain","Sri Lanka","Sudan","Suriname","Swaziland","Sweden","Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Togo","Tonga","Trinidad & Tobago","Tunisia","Turkey","Turkmenistan","Tuvalu","Uganda","Ukraine","United Arab Emirates","United Kingdom","United States","Uruguay","Uzbekistan","Vanuatu","Vatican City","Venezuela","Vietnam","Yemen","Zambia","Zimbabwe"]
  
  private var countriesPostSearch: [String] {
    guard let searchText = searchController.searchBar.text,
          !searchText.isEmpty else { return countries }
    
    return countries.filter { $0.lowercased().contains(searchText.lowercased()) }
  }
  
  private func countriesStartingWith(_ letter: Character) -> [String] {
    countriesPostSearch.filter { $0.starts(with: String(letter)) }
  }
  
  private lazy var searchController: UISearchController = {
    let searchController = UISearchController(searchResultsController: self)
    searchController.delegate = self
    searchController.searchResultsUpdater = self
    searchController.searchBar.autocapitalizationType = .words
    searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
    searchController.searchBar.delegate = self
    
    return searchController
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(tableView)
    
//    definesPresentationContext = true
    
    view.addSubview(searchController.searchBar)
    
    NSLayoutConstraint.activate([
      searchController.searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      searchController.searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      searchController.searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      
      tableView.topAnchor.constraint(equalTo: searchController.searchBar.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
}

extension CountrySearchController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    26
  }
  
  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map(String.init)
  }
      
  func tableView(_ tableView: UITableView,
                 sectionForSectionIndexTitle title: String,
                 at index: Int) -> Int {
      index
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let letter = Character(UnicodeScalar(65+section)!)
    return countriesStartingWith(letter).count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let letter = Character(UnicodeScalar(65+indexPath.section)!)
    let countriesWithLetter = countriesStartingWith(letter)
    
    cell.textLabel?.text = countriesWithLetter[indexPath.row]
    
    return cell
  }
}

extension CountrySearchController: UISearchControllerDelegate {
  
}

extension CountrySearchController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    print("UPDATING!!!!")
    tableView.reloadData()
  }
  
  
}

extension CountrySearchController: UISearchBarDelegate {
  
}
