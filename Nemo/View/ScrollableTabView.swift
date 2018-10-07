//
//  ScrollableTabView.swift
//  Nemo
//
//  Created by Dushyant Bansal on 03/10/18.
//  Copyright © 2018 Dushyant Bansal. All rights reserved.
//

import UIKit

protocol ScrollableTabViewDelegate: class {
  func reloadTab(_ button: TabButton)
  func closeTab(_ button: TabButton)
  func selectTab(_ button: TabButton)
}

class ScrollableTabView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
  var originalFrame: CGRect = CGRect.zero
  weak var stackView: UIStackView!
  weak var tabViewDelegate: ScrollableTabViewDelegate!
  
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
  
  func createTabButton() -> TabButton {
    let tabView = TabButton(frame: CGRect(x: 0,y: 0,width: 44,height: 44))
    tabView.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
    tabView.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
    let image = UIImageView(frame: tabView.bounds.insetBy(dx: 6, dy: 4))
    let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(updateCurrentWebView(_:)))
    singleTapGesture.numberOfTapsRequired = 1
    
    let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(reloadPage(_:)))
    doubleTapGesture.numberOfTapsRequired = 2
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    panGesture.delegate = self
    tabView.addGestureRecognizer(panGesture)

    //    singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
    tabView.addGestureRecognizer(singleTapGesture)
    tabView.addGestureRecognizer(doubleTapGesture)
    
    image.image = UIImage(named: "favicon")
    tabView.layer.cornerRadius = 2.0
    tabView.layer.masksToBounds = true
    tabView.layer.borderWidth = 1
    //    tabView.backgroundColor = UIColor.whiteColor()
    tabView.addSubview(image)
    
    addTabButton(tabView)
    return tabView
  }
  
  
  @objc func reloadPage(_ gesture: UIGestureRecognizer) {
    guard let button = gesture.view as? TabButton else {
      return
    }
    tabViewDelegate.reloadTab(button)
  }
  
  @objc func updateCurrentWebView(_ gesture: UIGestureRecognizer) {
    guard let button = gesture.view as? TabButton else {
      return
    }
    tabViewDelegate.selectTab(button)
  }
  
  
  @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    guard let button = gesture.view as? TabButton,
      let webVC = button.webVC else {
        return
    }
    switch gesture.state {
    case .began:
      originalFrame = button.frame
    case .changed:
      let point = gesture.translation(in: button.superview!)
      let frame = button.frame.offsetBy(dx: point.x, dy: point.y)
      button.frame = frame
      gesture.setTranslation(CGPoint.zero, in: button.superview!)
    case .ended:
      if button.frame.maxY < 0 {
        tabViewDelegate.closeTab(button)
      } else {
        button.frame = originalFrame
      }
    default:
      break
    }
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

extension ScrollableTabView: UIGestureRecognizerDelegate {
//  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//    guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
//      return false
//    }
//    
//    let vel = pan.velocity(in: self)
//    return abs(vel.y) > abs(vel.x)
//  }
}
