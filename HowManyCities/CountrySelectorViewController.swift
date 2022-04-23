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

protocol CountrySearchDelegate: AnyObject {
  var countries: [State] { get }
}


final class CountrySearchController: UIViewController {
//  private let countries = ["Afghanistan","Albania","Algeria","Andorra","Angola","Antigua & Deps","Argentina","Armenia","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bhutan","Bolivia","Bosnia Herzegovina","Botswana","Brazil","Brunei","Bulgaria","Burkina","Burundi","Cambodia","Cameroon","Canada","Cape Verde","Central African Rep","Chad","Chile","China","Colombia","Comoros","Congo","Congo {Democratic Rep}","Costa Rica","Croatia","Cuba","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","East Timor","Ecuador","Egypt","El Salvador","Equatorial Guinea","Eritrea","Estonia","Ethiopia","Fiji","Finland","France","Gabon","Gambia","Georgia","Germany","Ghana","Greece","Grenada","Guatemala","Guinea","Guinea-Bissau","Guyana","Haiti","Honduras","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland {Republic}","Israel","Italy","Ivory Coast","Jamaica","Japan","Jordan","Kazakhstan","Kenya","Kiribati","Korea North","Korea South","Kosovo","Kuwait","Kyrgyzstan","Laos","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macedonia","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Marshall Islands","Mauritania","Mauritius","Mexico","Micronesia","Moldova","Monaco","Mongolia","Montenegro","Morocco","Mozambique","Myanmar, {Burma}","Namibia","Nauru","Nepal","Netherlands","New Zealand","Nicaragua","Niger","Nigeria","Norway","Oman","Pakistan","Palau","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal","Qatar","Romania","Russian Federation","Rwanda","St Kitts & Nevis","St Lucia","Saint Vincent & the Grenadines","Samoa","San Marino","Sao Tome & Principe","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia","Solomon Islands","Somalia","South Africa","South Sudan","Spain","Sri Lanka","Sudan","Suriname","Swaziland","Sweden","Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Togo","Tonga","Trinidad & Tobago","Tunisia","Turkey","Turkmenistan","Tuvalu","Uganda","Ukraine","United Arab Emirates","United Kingdom","United States","Uruguay","Uzbekistan","Vanuatu","Vatican City","Venezuela","Vietnam","Yemen","Zambia","Zimbabwe"]
  
  private var specialSectionLabels: [GuessMode] = [.any, .every]
  
  private var countriesPostSearch: [State] {
    guard let searchText = searchBar.text,
          !searchText.isEmpty else { return countryDelegate?.countries ?? [] }
    
    return countryDelegate?.countries.filter { $0.name.lowercased().contains(searchText.lowercased()) } ?? []
  }
  
  private func countriesStartingWith(_ letter: Character) -> [State] {
    countriesPostSearch.filter { $0.name.starts(with: String(letter)) }
  }
  
//  private lazy var searchController: UISearchController = {
//    let searchController = UISearchController(searchResultsController: self)
//    searchController.delegate = self
//    searchController.searchResultsUpdater = self
//    searchController.searchBar.autocapitalizationType = .words
//    searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
//    searchController.searchBar.delegate = self
//
//    return searchController
//  }()
  
  private lazy var searchBar: UISearchBar = {
    let bar = UISearchBar().autolayoutEnabled
    bar.autocapitalizationType = .words
    bar.delegate = self
    
    
    return bar
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  weak var countryDelegate: CountrySearchDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
    
    view.addSubview(tableView)
    
//    definesPresentationContext = true
    
    view.addSubview(searchBar)
    
    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      
      tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
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
}

extension CountrySearchController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    tableView.reloadData()
  }
}
