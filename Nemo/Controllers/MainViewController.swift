//
//ther  ViewController.swift
//  Nemo
//
//  Created by Dushyant Bansal on 02/07/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit

protocol MainVCWebDelegate: class {
  func webVC(_ webVC: WebViewController, faviconDidLoad image: UIImage)
  func webVC(_ webVC: WebViewController, shouldOpenNewTabForURL url: URL)
  func hideTabBarFooter()
  func showTabBarFooter()
}

class MainViewController: UIViewController, UIGestureRecognizerDelegate {

  typealias Tab = (webVC: WebViewController, button: TabButton, index: Int)
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var footerView: UIView!
  @IBOutlet weak var footerScrollView: ScrollableTabView!
  @IBOutlet weak var footerNewTabView: UIView!
  
  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var rightButton: UIButton!
  @IBOutlet weak var footerHeightConstraint: NSLayoutConstraint!
  
  var originalFrame: CGRect = CGRect.zero
  var viewControllers: [WebViewController] = []
  var lastRemovedTab: Tab? = nil
  
  @IBOutlet weak var footerOffsetConstraint: NSLayoutConstraint!
  @IBOutlet weak var undoButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    leftButton.tintColor = undoButton.tintColor
    rightButton.tintColor = undoButton.tintColor
    createAndUpdateNewWebView()
    
    undoButton.setTitle("Undo", for: UIControl.State())
    undoButton.isHidden = true
    undoButton.addTarget(self, action: #selector(undoRemoveWebView), for: .touchUpInside)
    footerView.backgroundColor = UIColor(red: (247.0/255.0), green:(247.0/255.0) , blue:(247.0/255.0) , alpha: 1)
    footerNewTabView.backgroundColor = UIColor(red: (247.0/255.0), green:(247.0/255.0) , blue:(247.0/255.0) , alpha: 1)
    footerScrollView.scrollsToTop = false
    
    footerScrollView.tabViewDelegate = self
    contentView.backgroundColor = UIColor.darkGray
  }
  
  func addPanGestures() {
    let leftScreenEdgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgePanGesture(_:)))
    leftScreenEdgePanGesture.edges = UIRectEdge.left
    view.addGestureRecognizer(leftScreenEdgePanGesture)
    
    let rightScreenEdgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgePanGesture(_:)))
    rightScreenEdgePanGesture.edges = UIRectEdge.right
    view.addGestureRecognizer(rightScreenEdgePanGesture)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    textField.resignFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    footerScrollView.setContentOffset(CGPoint(x: footerScrollView.contentSize.width, y: 44), animated: false)
  }
  
  func button(forVC vc: WebViewController) -> TabButton? {
    return footerScrollView.tabViews.filter { (view) -> Bool in
      if let button = view as? TabButton {
        return button.webVC == vc
      }
      return false
    }.first as? TabButton
  }
  
  func selectedWebVC() -> WebViewController {
    return children.first as! WebViewController
  }
  
  func hideCurrentWebView() {
    guard let vc = children.first as? WebViewController else {
      return
    }
    
    vc.view.removeFromSuperview()
    vc.willMove(toParent: nil)
    vc.removeFromParent()
    
    button(forVC: vc)?.layer.borderColor = UIColor.clear.cgColor
  }
  
  @IBOutlet weak var goBack: UIButton!
  @IBOutlet weak var goForward: UIButton!
  
  @IBAction func goBack(_ sender: AnyObject) {
    selectedWebVC().webView.goBack()
  }
  
  @IBAction func goForward(_ sender: AnyObject) {
    selectedWebVC().webView.goForward()
  }
  
  @IBAction func addNewTab(_ sender: AnyObject) {
    createAndUpdateNewWebView()
  }
  
  @objc func undoRemoveWebView() {
    guard let lastRemovedTab = lastRemovedTab else{
      return
    }
    lastRemovedTab.button.webVC = lastRemovedTab.webVC
    addWebView(lastRemovedTab.webVC, index: lastRemovedTab.index)
    footerScrollView.addTabButton(lastRemovedTab.button, index: lastRemovedTab.index)
  }
  
  func removeWebView(_ webVC: WebViewController, button: TabButton) {
    guard let index = viewControllers.index(of: webVC) else {
      return
    }
    
    lastRemovedTab = (webVC, button, index)
    undoButton.isHidden = false
    Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hideUndoButton), userInfo: nil, repeats: false)
    footerScrollView.removeTabView(button)
    button.removeFromSuperview()
    if children.first == webVC {
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
    viewControllers.remove(at: index)
  }
  
  @objc func hideUndoButton() {
    undoButton.isHidden = true
    lastRemovedTab = nil
  }
  
  @objc func handleScreenEdgePanGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
    let webView = selectedWebVC().webView
    let centerX = (webView?.frame.width)!/2
    
    switch gesture.state {
    case .began:
      originalFrame = (webView?.frame)!
    case .changed:
      let point = gesture.translation(in: view)
      let frame = webView?.frame.offsetBy(dx: point.x, dy: 0)
      webView?.frame = frame!
      gesture.setTranslation(CGPoint.zero, in: view)
    case .ended:
      if (webView?.frame.minX)! > centerX { //swipe right
        selectedWebVC().webView.goBack()
      } else if (webView?.frame.maxX)! < centerX { //swipe left
        selectedWebVC().webView.goForward()
      }
      webView?.frame = originalFrame
    default:
      break
    }
  }
  
  func updateWebView(_ webVC: WebViewController) {
    webVC.view.frame = contentView.bounds
    
    addChild(webVC)
    contentView.addSubview(webVC.view)
    webVC.didMove(toParent: self)
    
    if let button = button(forVC: webVC) {
      button.layer.borderColor = button.tintColor.cgColor
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
    let webVC = sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
    webVC.delegate = self
    return webVC
  }
  
  func addWebView(_ webVC: WebViewController, index: Int? = nil) {
    if let index = index {
      viewControllers.insert(webVC, at: index)
    } else {
      viewControllers.append(webVC)
    }
  }
  
  //MARK: Footer stack view
  func createAndAddTabButtonToFooter(_ webVC: WebViewController) {
    let button = footerScrollView.createTabButton()
    button.webVC = webVC
  }

  func updateFooter(_ webVC: WebViewController) {
  }
}

extension MainViewController: MainVCWebDelegate {
  func webVC(_ webVC: WebViewController, faviconDidLoad image: UIImage) {
    guard viewControllers.index(of: webVC) != nil else {
      return
    }
    
    DispatchQueue.main.async {
      if let tabView = self.button(forVC: webVC),
        let imageView = tabView.subviews.first as? UIImageView {
        imageView.image = image
      }
    }
  }
  
  func webVC(_ webVC: WebViewController, shouldOpenNewTabForURL url: URL) {
    let webVC = createNewWebView()
    webVC.url = url
    addWebView(webVC)
    
    updateWebView(webVC)
    hideCurrentWebView()
    
    createAndAddTabButtonToFooter(webVC)
  }
  
  func hideTabBarFooter() {
    footerHeightConstraint.constant = 0
  }
  
  func showTabBarFooter() {
    footerHeightConstraint.constant = 52
  }
}

extension MainViewController: ScrollableTabViewDelegate {
  func reloadTab(_ button: TabButton) {
    button.webVC?.reloadPage()
  }
  
  func closeTab(_ button: TabButton) {
    if let webVC = button.webVC {
      removeWebView(webVC, button: button)
    }
  }
  
  func selectTab(_ button: TabButton) {
    hideCurrentWebView()
    updateWebView(button.webVC!)
  }
}

