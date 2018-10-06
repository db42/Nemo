//
//  ScrollableTabView.swift
//  Nemo
//
//  Created by Dushyant Bansal on 03/10/18.
//  Copyright © 2018 Dushyant Bansal. All rights reserved.
//

import UIKit

class ScrollableTabView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  weak var stackView: UIStackView!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: stackView, attribute: .top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: stackView, attribute: .left, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: stackView, attribute: .right, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: stackView, attribute: .bottom, multiplier: 1, constant: 0)
      ])
    self.stackView = stackView
  }
  
  var tabViews: [UIView] {
    return stackView?.subviews ?? []
  }
  
  func addTabView(_ button: UIView) {
    stackView?.addArrangedSubview(button)
  }
  
  func insertTabView(_ button: UIView, at index: Int) {
    stackView.insertArrangedSubview(button, at: index)
  }
  
  func removeTabView(_ button: UIView) {
    stackView.removeArrangedSubview(button)
  }
  
  func addTabButton(_ button: UIView, index: Int? = nil) {
    if let index = index {
      insertTabView(button, at: index)
      return
    }
    
    addTabView(button)
    let x = contentSize.width + button.bounds.width - bounds.width
    if x > 0 {
      setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
  }
}
