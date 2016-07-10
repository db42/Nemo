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
  
  func removeCurrentWebView() {
    if let vc = childViewControllers.first {
      vc.view.removeFromSuperview()
      vc.willMoveToParentViewController(nil)
      vc.removeFromParentViewController()
    }
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
    button.addTarget(self, action: #selector(createAndUpdateNewWebView), forControlEvents: .TouchUpInside)
    
    footerNewTabView.addSubview(button)
  }
  
  func addToFooter(webVC: WebViewController) {
    let button = UIButton(type: .System)
    button.addTarget(self, action: #selector(updateCurrentWebView(_:)), forControlEvents: .TouchUpInside)
    guard let index = viewControllers.indexOf(webVC) else {
      return
    }
    
    button.tag = index
    button.setTitle("\(index)", forState: .Normal)
    footerStackView.addArrangedSubview(button)
  }
  
  func updateCurrentWebView(button: UIButton) {
    removeCurrentWebView()
    let index = button.tag
    let webVC = viewControllers[index]
    updateWebView(webVC)
  }
  
  func updateFooter(webVC: WebViewController) {
  }


}

