//
//  MapGuessStatsBar.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import UIKit

final class MapGuessStatsBar: UIView {

  private lazy var numCitiesGuessedLabel: CounterLabel = {
    let label = CounterLabel(title: "#cities", count: 0, formatOption: .integer).autolayoutEnabled
    label.numberOfLines = 1
    label.setContentHuggingPriority(.required, for: .horizontal)
    label.textAlignment = .left
    
    return label
  }()
  
  private lazy var populationGuessedLabel: CounterLabel = {
    let label = CounterLabel(title: "pop", count: 0, formatOption: .abbreviatedInteger).autolayoutEnabled
    label.numberOfLines = 1
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    label.textAlignment = .center
    
    return label
  }()
  
  private lazy var percentageTotalPopulationLabel: CounterLabel = {
    let label = CounterLabel(title: "% total", count: 0, formatOption: .percent).autolayoutEnabled
    label.numberOfLines = 1
    label.setContentHuggingPriority(.required, for: .horizontal)
    label.textAlignment = .right
    
    return label
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView().autolayoutEnabled
    stackView.axis = .horizontal
    stackView.spacing = 8.0
    
    return stackView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    stackView.addArrangedSubviews([numCitiesGuessedLabel,
                                   populationGuessedLabel,
                                   percentageTotalPopulationLabel])
    
    addSubview(stackView)
    stackView.pin(to: self, margins: .init(horizontal: 8, vertical: 4))
  }
  
  func updateNumCitiesGuessed(_ value: Int) {
    numCitiesGuessedLabel.count = value.asDouble
  }
  
  func updatePopulationGuessed(_ value: Int) {
    populationGuessedLabel.count = value.asDouble
  }
  
  func updatePercentageTotalPopulation(_ value: Double) {
    percentageTotalPopulationLabel.count = value
  }
}


final class CounterLabel: UILabel {
  let title: String
  var count: Double {
    didSet {
      updateLabel()
    }
  }
  var formatOption: CounterFormat
  
  init(title: String, count: Double, formatOption: CounterFormat = .plain) {
    self.title = title
    self.count = count
    self.formatOption = formatOption
    super.init(frame: .zero)
    updateLabel()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func updateLabel() {
    text = "\(title): \(formattedCount)"
  }
  
  private var formattedCount: String {
    switch formatOption {
      case .integer:
        return "\(count.asInt)"
      case .abbreviatedInteger:
        return "\(count.asInt.abbreviated)"
      case .percent:
        let fmt = NumberFormatter()
        fmt.minimumFractionDigits = 0
        fmt.maximumFractionDigits = 2
        fmt.roundingMode = .halfUp
        fmt.numberStyle = .percent
        return fmt.string(from: count.asNSNumber) ?? "\(count)"
      case .plain:
        return "\(count)"
    }
  }
}

enum CounterFormat {
  case integer
  case abbreviatedInteger
  case percent
  case plain
}
