//
//  NSDiffableDataSourceSnapshot+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/6/22.
//

import Foundation
import UIKit

extension NSDiffableDataSourceSnapshot {
  
  /// Add those sections to the snapshot which are not currently present in the snapshot
  /// - Parameter sections: The sections desired to be added
  mutating func appendSectionsIfNecessary(_ sections: [SectionIdentifierType]) {
    let missingSections = sections.filter { indexOfSection($0) == nil }
    appendSections(missingSections)
  }
  
  mutating func reloadItems(inSection section: SectionIdentifierType) {
    reloadItems(itemIdentifiers(inSection: section))
  }
  
  mutating func reconfigureItems(inSection section: SectionIdentifierType) {
    reconfigureItems(itemIdentifiers(inSection: section))
  }
  
  mutating func deleteItems(inSection section: SectionIdentifierType) {
    deleteItems(itemIdentifiers(inSection: section))
  }
}
