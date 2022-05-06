//
//  ChartCollectionViewCell.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/28/22.
//

import UIKit
import Charts

final class ChartCollectionViewCell: UICollectionViewCell {
  static let identifier = "ChartCollectionViewCell"
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView().autolayoutEnabled
    stackView.spacing = 16.0
    stackView.axis = .vertical
    stackView.alignment = .leading
    
    return stackView
  }()
  
  private lazy var headerLabel: UILabel = {
    let label = UILabel(text: "", style: UIFont.TextStyle.largeTitle).autolayoutEnabled
    label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
    
    return label
  }()
  
  private lazy var barChartView: HorizontalBarChartView = {
    let barChart = HorizontalBarChartView().autolayoutEnabled
//    barChart.rotationEnabled = false
//    barChart.transparentCircleRadiusPercent = 0.45
//    barChart.holeRadiusPercent = 0.33
    barChart.highlightPerTapEnabled = false
    barChart.setContentCompressionResistancePriority(.required, for: .horizontal)
    barChart.setContentCompressionResistancePriority(.required, for: .vertical)
    barChart.pinchZoomEnabled = false
    barChart.isUserInteractionEnabled = false
    
    barChart.leftAxis.drawAxisLineEnabled = true
    barChart.rightAxis.drawAxisLineEnabled = true
    barChart.leftAxis.drawGridLinesEnabled = false
    barChart.leftAxis.drawZeroLineEnabled = false
    barChart.leftAxis.axisMinimum = 0
    barChart.rightAxis.axisMinimum = 0
    
    
    barChart.xAxis.drawGridLinesEnabled = false
    barChart.xAxis.labelPosition = .bottom
    barChart.xAxis.labelFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    
    barChart.legend.entries = []
//    pieChart.legend.horizontalAlignment = .left
//    pieChart.legend.verticalAlignment = .top
//    pieChart.legend.orientation = .vertical
    
//    barChart.entryLabelFont = .boldSystemFont(ofSize: UIFont.systemFontSize)
    
    return barChart
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
//    barChartView.holeColor = .systemBackground
    
    stackView.addArrangedSubviews([headerLabel, barChartView])
    barChartView.pinSides(to: stackView)
    headerLabel.pinSides(to: stackView)
    
    barChartView.heightAnchor.constraint(equalTo: barChartView.widthAnchor).isActive = true
    
    contentView.addSubview(stackView)
    
    stackView.pin(to: contentView.safeAreaLayoutGuide)
  }
  
  func configure(title: String, data: [String: [City]], threshold: Int = 7) {
    headerLabel.text = title
    let rawEntries = data.sorted {
      $0.value.count > $1.value.count
    }
//    let rawEntries = data.map { (stateName, cities) -> PieChartDataEntry in
//        .init(value: Double(cities.count), label: stateName)
//    }.sorted { $0.value > $1.value }
//      .enumerated()
      
    var entries = [BarChartDataEntry]()
    for (index, element) in rawEntries.enumerated() {
      if index < threshold {
        entries.append(.init(x: Double(index), y: Double(element.value.count))) // TODO: VERIFY
//        entries.append(.init(x: element.key, y: Double(element.value.count)))
//        entries.append(.init(value: floor(Double(element.value.count)), label: element.key))
      } else {
        break
//        entries[entries.count - 1].label = "Others"
//        entries[entries.count - 1].value += Double(element.value.count)
      }
    }
    
    let vf = StateNameValueFormatter()
    vf.stateNames = rawEntries.map { $0.key }
    barChartView.xAxis.valueFormatter = vf
    
    let dataSet = BarChartDataSet(entries: entries)
    dataSet.colors = ChartColorTemplates.pastel()
//    dataSet.entryLabelFont = .boldSystemFont(ofSize: UIFont.systemFontSize)
    
    let data = BarChartData(dataSet: dataSet)
    data.setValueFont(.systemFont(ofSize: UIFont.systemFontSize))
    
    let fmt = NumberFormatter()
    fmt.generatesDecimalNumbers = false
    fmt.numberStyle = .none
    fmt.maximumFractionDigits = 0
    fmt.multiplier = 1
    fmt.alwaysShowsDecimalSeparator = false
    data.setValueFormatter(DefaultValueFormatter(formatter: fmt))
    
    barChartView.data = data
//    pieChartView.setNeedsDisplay()
  }
}

class StateNameValueFormatter: AxisValueFormatter {
  var stateNames: [String]! // TODO: I can only assume I'm doing this with the right paradigm because the docs suck
  func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    
    let state = State(name: stateNames[Int(value)])
    if let locale = state.locale, let flag = state.flag {
      return "\(flag)\(locale)"
    } else {
      return state.name
    }
  }
}
