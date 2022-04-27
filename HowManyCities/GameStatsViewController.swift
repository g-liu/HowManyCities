//
//  GameStatsViewController.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/27/22.
//

import UIKit

final class GameStatsViewController: UIViewController {
  var statsDelegate: GameStatisticsDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    title = "Statistics"
    navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(closeIt))
    
    view.backgroundColor = .systemBackground
    
    guard let statsDelegate = statsDelegate else {
      return
    }
    
    let stackView = UIStackView().autolayoutEnabled
    stackView.axis = .vertical
    
    stackView.addArrangedSubview(createLabel(text: "Cities guessed: \(statsDelegate.numCitiesGuessed)"))
    
    stackView.addArrangedSubview(createLabel(text: "***BIGGEST CITIES***"))
    statsDelegate.largestCitiesGuessed.forEach {
      let label = createLabel(text: "\($0.fullTitle) - \($0.population.commaSeparated)")
      stackView.addArrangedSubview(label)
    }
    
    stackView.addArrangedSubview(createLabel(text: "**** BEST COUNTRIES ****"))
    statsDelegate.citiesByCountry.sorted { $0.value.count > $1.value.count }.forEach {
      let label = createLabel(text: "\($0.key): \($0.value.count) (pop: \($0.value.totalPopulation.commaSeparated))")
      stackView.addArrangedSubview(label)
    }
    
    view.addSubview(stackView)
    stackView.pin(to: view.safeAreaLayoutGuide)
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
