//
//  NumberedListCollectionViewCell.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import UIKit

final class NumberedListCollectionViewCell: UICollectionViewCell {
  func configure<I: ItemRenderer>(item: I.ItemType, renderer: I) {
    contentView.removeSubviews()
    guard let view = renderer.render(item)?.autolayoutEnabled else { return }
    contentView.addSubview(view)
    view.pin(to: contentView.safeAreaLayoutGuide)
  }
}
