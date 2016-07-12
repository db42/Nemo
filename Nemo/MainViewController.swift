//
//  ViewController.swift
//  Nemo
//
//  Created by Dushyant Bansal on 02/07/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIGestureRecognizerDelegate {

  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var footerView: UIView!
  @IBOutlet weak var footerScrollView: UIScrollView!
  @IBOutlet weak var footerNewTabView: UIView!
  @IBOutlet weak var footerStackView: UIStackView!
  
  var originalFrame: CGRect = CGRectZero
  var viewControllers: [WebViewController] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    createAndUpdateNewWebView()
    
    footerView.backgroundColor = UIColor(white: 0.2, alpha: 0.1)
    addNewTabButton()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
      footerScrollView.setContentOffset(CGPointMake(footerScrollView.contentSize.width, 44), animated: false)
  }
  
  func button(forVC vc: WebViewController) -> TabButton? {
    return footerStackView.subviews.filter { (view) -> Bool in
      if let button = view as? TabButton {
        return button.webVC == vc
      }
      return false
    }.first as? TabButton
  }
  
  func hideCurrentWebView() {
    guard let vc = childViewControllers.first as? WebViewController else {
      return
    }
    
    vc.view.removeFromSuperview()
    vc.willMoveToParentViewController(nil)
    vc.removeFromParentViewController()
    
    button(forVC: vc)?.layer.borderColor = UIColor.clearColor().CGColor
  }
  
  func addNewTab() {
    hideCurrentWebView()
    createAndUpdateNewWebView()
  }
  
  func removeWebView(webVC: WebViewController, button: TabButton) {
    guard let index = viewControllers.indexOf(webVC) else {
      return
    }
    footerStackView.removeArrangedSubview(button)
    if childViewControllers.first == webVC {
      hideCurrentWebView()
      var newVC: WebViewController
      if viewControllers.count == 1 {
        newVC = createNewWebView()
      } else {
        let newTabIndex = index > 0 ? index - 1 : viewControllers.count - 1
        newVC = viewControllers[newTabIndex]
      }
      updateWebView(newVC)
    }
    viewControllers.removeAtIndex(index)
  }
  
  func updateWebView(webVC: WebViewController) {
    webVC.view.frame = contentView.bounds
    
    addChildViewController(webVC)
    contentView.addSubview(webVC.view)
    webVC.didMoveToParentViewController(self)
    
    if let button = button(forVC: webVC) {
      button.layer.borderColor = button.tintColor.CGColor
    }
  }
  
  func createAndUpdateNewWebView() {
    let webVC = createNewWebView()
    updateWebView(webVC)
  }
  
  func createNewWebView() -> WebViewController {
    let sb = UIStoryboard(name: "Main", bundle: nil)
    let webVC = sb.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
    viewControllers.append(webVC)
    addToFooter(webVC)
    return webVC
  }
  
  func addNewTabButton() {
//    let x = footerView.bounds.maxX - 50
//    let y = footerView.bounds.midY - 22
//    let frame = CGRectMake(x, y, 44, 44)
    let button = UIButton(type: .ContactAdd)
//    let frame = footerNewTabView.bounds
//    let button = UIButton(frame: frame)
//    button.backgroundColor = UIColor.grayColor()
//    button.layer.cornerRadius = 22
//    button.layer.masksToBounds = true
    button.addTarget(self, action: #selector(addNewTab), forControlEvents: .TouchUpInside)
    
    footerNewTabView.addSubview(button)
  }
  
  func addToFooter(webVC: WebViewController) {
    guard let index = viewControllers.indexOf(webVC) else {
      return
    }
    
    let button = TabButton(type: .System)
    let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(updateCurrentWebView(_:)))
    singleTapGesture.numberOfTapsRequired = 1
    
    let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(reloadPage(_:)))
    doubleTapGesture.numberOfTapsRequired = 2
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    panGesture.delegate = self
    button.addGestureRecognizer(panGesture)
    
    singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
    button.addGestureRecognizer(singleTapGesture)
    button.addGestureRecognizer(doubleTapGesture)
    
    button.webVC = webVC
    button.setTitle("\(index)", forState: .Normal)
    button.layer.cornerRadius = button.bounds.height/2.0
    button.layer.masksToBounds = true
    button.layer.borderWidth = 1
    button.layer.borderColor = button.tintColor.CGColor
    footerStackView.addArrangedSubview(button)
    
    let x = footerScrollView.contentSize.width - footerScrollView.bounds.width
    if x > 0 {
      footerScrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
  }
  
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
      return false
    }
    
    let vel = pan.velocityInView(view)
    return fabs(vel.y) > fabs(vel.x)
  }
  
  func handlePanGesture(gesture: UIPanGestureRecognizer) {
    guard let button = gesture.view as? TabButton,
    webVC = button.webVC else {
      return
    }
    switch gesture.state {
    case .Began:
      originalFrame = button.frame
    case .Changed:
      let point = gesture.translationInView(view)
      let frame = button.frame.offsetBy(dx: point.x, dy: point.y)
      button.frame = frame
      gesture.setTranslation(CGPointZero, inView: view)
    case .Ended:
      if button.frame.maxY < 0 {
        removeWebView(webVC, button: button)
      } else {
        button.frame = originalFrame
      }
    default:
      break
    }
  }
  
  func reloadPage(gesture: UIGestureRecognizer) {
    guard let button = gesture.view as? TabButton else {
      return
    }
    button.webVC?.reloadPage()
  }
  
  func updateCurrentWebView(gesture: UIGestureRecognizer) {
    guard let button = gesture.view as? TabButton else {
      return
    }
    hideCurrentWebView()
    updateWebView(button.webVC!)
  }
  
  func updateFooter(webVC: WebViewController) {
  }


}

