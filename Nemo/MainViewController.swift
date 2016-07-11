//
//  ViewController.swift
//  Nemo
//
//  Created by Dushyant Bansal on 02/07/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var footerView: UIView!
  @IBOutlet weak var footerScrollView: UIScrollView!
  @IBOutlet weak var footerNewTabView: UIView!
  @IBOutlet weak var footerStackView: UIStackView!
  
  static var tabCount = 0
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
  
  func button(forVC vc: WebViewController) -> UIButton? {
    if let index = viewControllers.indexOf(vc),
      button = footerStackView.viewWithTag(index + 1000) as? UIButton {
      return button
    }
    return nil
  }
  
  func removeCurrentWebView() {
    guard let vc = childViewControllers.first as? WebViewController else {
      return
    }
    
    vc.view.removeFromSuperview()
    vc.willMoveToParentViewController(nil)
    vc.removeFromParentViewController()
    
    button(forVC: vc)?.layer.borderColor = UIColor.clearColor().CGColor
  }
  
  func addNewTab() {
    removeCurrentWebView()
    createAndUpdateNewWebView()
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
    let sb = UIStoryboard(name: "Main", bundle: nil)
    let webVC = sb.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
    viewControllers.append(webVC)
    updateWebView(webVC)
    addToFooter(webVC)
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
    let button = UIButton(type: .System)
    button.addTarget(self, action: #selector(updateCurrentWebView(_:)), forControlEvents: .TouchUpInside)
    guard let index = viewControllers.indexOf(webVC) else {
      return
    }
    
    button.tag = index + 1000
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
  
  func updateCurrentWebView(button: UIButton) {
    removeCurrentWebView()
    let index = button.tag - 1000
    let webVC = viewControllers[index]
    updateWebView(webVC)
  }
  
  func updateFooter(webVC: WebViewController) {
  }


}

