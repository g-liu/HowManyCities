//
//  PagingFooterCollectionReusableView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/4/22.
//

import UIKit
import Combine

struct PagingInfo: Equatable, Hashable {
  // TODO: Not using this capability yet. Future?
  //  let sectionIndex: Int
  let currentPage: Int
}

// stolen from https://nemecek.be/blog/141/how-to-show-page-indicator-with-compositional-layout
// TODO: Make it a 2 way binding
final class PagingFooterCollectionReusableView: UICollectionReusableView {
  private lazy var pageControl: UIPageControl = {
    let control = UIPageControl().autolayoutEnabled
    control.isUserInteractionEnabled = false // because it's a one way binding now...
    control.currentPageIndicatorTintColor = .systemFill
    control.pageIndicatorTintColor = .systemGray5
    return control
  }()
  
  private var pagingInfoToken: AnyCancellable?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  func configure(with numberOfPages: Int) {
    pageControl.numberOfPages = numberOfPages
  }
  
  func subscribeTo(subject: PassthroughSubject<PagingInfo, Never>, for section: Int) {
    pagingInfoToken = subject
    //              .filter { $0.sectionIndex == section }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] pagingInfo in
        self?.pageControl.currentPage = pagingInfo.currentPage
      }
  }
  
  private func setupView() {
    backgroundColor = .clear
    
    addSubview(pageControl)
    
    NSLayoutConstraint.activate([
      pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
      pageControl.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    pagingInfoToken?.cancel()
    pagingInfoToken = nil
  }
}
