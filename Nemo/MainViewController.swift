//
//ther  ViewController.swift
//  Nemo
//
//  Created by Dushyant Bansal on 02/07/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit

protocol MainVCWebDelegate: class {
  func webVC(webVC: WebViewController, faviconDidLoad image: UIImage)
  func webVC(webVC: WebViewController, shouldOpenNewTabForURL url: NSURL)
}

class MainViewController: UIViewController, UIGestureRecognizerDelegate, MainVCWebDelegate {

  typealias Tab = (webVC: WebViewController, button: TabButton, index: Int)
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var footerView: UIView!
  @IBOutlet weak var footerScrollView: UIScrollView!
  @IBOutlet weak var footerNewTabView: UIView!
  @IBOutlet weak var footerStackView: UIStackView!
  
  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var rightButton: UIButton!
  var originalFrame: CGRect = CGRectZero
  var viewControllers: [WebViewController] = []
  var lastRemovedTab: Tab? = nil
  
  @IBOutlet weak var undoButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    leftButton.tintColor = undoButton.tintColor
    rightButton.tintColor = undoButton.tintColor
    createAndUpdateNewWebView()
    
    undoButton.setTitle("Undo", forState: .Normal)
    undoButton.hidden = true
    undoButton.addTarget(self, action: #selector(undoRemoveWebView), forControlEvents: .TouchUpInside)
    footerView.backgroundColor = UIColor(red: (247.0/255.0), green:(247.0/255.0) , blue:(247.0/255.0) , alpha: 1)
    footerNewTabView.backgroundColor = UIColor(red: (247.0/255.0), green:(247.0/255.0) , blue:(247.0/255.0) , alpha: 1)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    textField.resignFirstResponder()
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
  
  func selectedWebVC() -> WebViewController {
    return childViewControllers.first as! WebViewController
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
  @IBOutlet weak var goBack: UIButton!
  @IBOutlet weak var goForward: UIButton!
  
  @IBAction func goBack(sender: AnyObject) {
    selectedWebVC().webView.goBack()
  }
  
  @IBAction func goForward(sender: AnyObject) {
    selectedWebVC().webView.goForward()
  }
  
  @IBAction func addNewTab(sender: AnyObject) {
    createAndUpdateNewWebView()
  }
  
  func undoRemoveWebView() {
    guard let lastRemovedTab = lastRemovedTab else{
      return
    }
    lastRemovedTab.button.webVC = lastRemovedTab.webVC
    addWebView(lastRemovedTab.webVC, index: lastRemovedTab.index)
    addTabButton(lastRemovedTab.button, index: lastRemovedTab.index)
  }
  
  func removeWebView(webVC: WebViewController, button: TabButton) {
    guard let index = viewControllers.indexOf(webVC) else {
      return
    }
    
    lastRemovedTab = (webVC, button, index)
    undoButton.hidden = false
    NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(hideUndoButton), userInfo: nil, repeats: false)
    footerStackView.removeArrangedSubview(button)
    button.removeFromSuperview()
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
  
  func hideUndoButton() {
    undoButton.hidden = true
    lastRemovedTab = nil
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
    hideCurrentWebView()
    let webVC = createNewWebView()
    addWebView(webVC)
    updateWebView(webVC)
    
    createAndAddTabButtonToFooter(webVC)
  }
  
  func createNewWebView() -> WebViewController {
    let sb = UIStoryboard(name: "Main", bundle: nil)
    let webVC = sb.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
    webVC.delegate = self
    return webVC
  }
  
  func addWebView(webVC: WebViewController, index: Int? = nil) {
    if let index = index {
      viewControllers.insert(webVC, atIndex: index)
    } else {
      viewControllers.append(webVC)
    }
  }
  
  func createTabButton(webVC: WebViewController) -> TabButton? {
//    guard let index = viewControllers.indexOf(webVC) else {
//      return nil
//    }
    
    let tabView = TabButton(frame: CGRectMake(0,0,44,44))
    tabView.heightAnchor.constraintEqualToConstant(44.0).active = true
    tabView.widthAnchor.constraintEqualToConstant(44.0).active = true
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
    tabView.webVC = webVC
    tabView.addSubview(image)
    return tabView
  }
  
  func addTabButton(button: UIView, index: Int? = nil) {
    if let index = index {
      footerStackView.insertArrangedSubview(button, atIndex: index)
      return
    }
    
    footerStackView.addArrangedSubview(button)
//    footerScrollView.contentSize = CGSize(width: footerStackView.frame.width, height: footerStackView.frame.height)
    let x = footerScrollView.contentSize.width + button.bounds.width - footerScrollView.bounds.width
    if x > 0 {
      footerScrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  }
  
  func createAndAddTabButtonToFooter(webVC: WebViewController) {
    let button = createTabButton(webVC)
    addTabButton(button!)
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
  
  func webVC(webVC: WebViewController, faviconDidLoad image: UIImage) {
    guard let index = viewControllers.indexOf(webVC) else {
      return
    }
    
    dispatch_async(dispatch_get_main_queue()) {
      if let tabView = self.button(forVC: webVC),
      imageView = tabView.subviews.first as? UIImageView {
       imageView.image = image
      }
    }
  }
  
  func webVC(webVC: WebViewController, shouldOpenNewTabForURL url: NSURL) {
    let webVC = createNewWebView()
    webVC.url = url
    addWebView(webVC)
    
    updateWebView(webVC)
    hideCurrentWebView()
    
    createAndAddTabButtonToFooter(webVC)
  }

}

