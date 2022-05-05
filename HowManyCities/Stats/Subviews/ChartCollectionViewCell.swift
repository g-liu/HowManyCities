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
  
  private lazy var pieChart: PieChartView = {
    let pieChart = PieChartView().autolayoutEnabled
    pieChart.rotationEnabled = false
    pieChart.transparentCircleRadiusPercent = 0.45
    pieChart.holeRadiusPercent = 0.33
    pieChart.highlightPerTapEnabled = false

    return pieChart
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
    contentView.addSubview(pieChart)
    pieChart.holeColor = .systemBackground
    pieChart.pin(to: contentView.safeAreaLayoutGuide)
  }
  
  func setData(_ data: [String: [City]], threshold: Int = 7) {
    let rawEntries = data.sorted {
      $0.value.count > $1.value.count
    }
//    let rawEntries = data.map { (stateName, cities) -> PieChartDataEntry in
//        .init(value: Double(cities.count), label: stateName)
//    }.sorted { $0.value > $1.value }
//      .enumerated()
      
    var entries = [PieChartDataEntry]()
    for (index, element) in rawEntries.enumerated() {
      if index < threshold {
        entries.append(.init(value: floor(Double(element.value.count)), label: element.key))
      } else {
        break
//        entries[entries.count - 1].label = "Others"
//        entries[entries.count - 1].value += Double(element.value.count)
      }
    }
    let dataSet = PieChartDataSet(entries: entries)
    dataSet.colors = ChartColorTemplates.pastel()
    
    let data = PieChartData(dataSet: dataSet)
    
    let fmt = NumberFormatter()
    fmt.generatesDecimalNumbers = false
    fmt.numberStyle = .none
    fmt.maximumFractionDigits = 0
    fmt.alwaysShowsDecimalSeparator = false
    data.setValueFormatter(DefaultValueFormatter(formatter: fmt))
    
    pieChart.data = data
    pieChart.setNeedsDisplay()
  }
}
