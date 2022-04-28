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
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  private func setupView() {
    // TODO: ALL TEMPORARY
    let entries: [PieChartDataEntry] = [
      .init(value: 20, label: "China"),
      .init(value: 20, label: "United States"),
      .init(value: 14, label: "India"),
      .init(value: 3, label: "others"),
      ]
    
    let dataSet = PieChartDataSet(entries: entries, label: "Countries by cities guessed")
    let data = PieChartData(dataSet: dataSet)
    
    dataSet.colors = ChartColorTemplates.pastel()
    
    let pieChart = PieChartView().autolayoutEnabled
    pieChart.data = data
    pieChart.rotationEnabled = false
    pieChart.transparentCircleRadiusPercent = 0.45
    pieChart.holeRadiusPercent = 0.33
    
    contentView.addSubview(pieChart)
    pieChart.pin(to: contentView.safeAreaLayoutGuide)
    pieChart.setNeedsDisplay()
  }
}
