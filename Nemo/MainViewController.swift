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
  @IBOutlet weak var footerScrollView: UIScrollView!
  @IBOutlet weak var footerNewTabView: UIView!
  @IBOutlet weak var footerStackView: UIStackView!
  
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
    
    contentView.backgroundColor = UIColor.darkGray
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    textField.resignFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    footerScrollView.setContentOffset(CGPoint(x: footerScrollView.contentSize.width, y: 44), animated: false)
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
    addTabButton(lastRemovedTab.button, index: lastRemovedTab.index)
  }
  
  func removeWebView(_ webVC: WebViewController, button: TabButton) {
    guard let index = viewControllers.index(of: webVC) else {
      return
    }
    
    lastRemovedTab = (webVC, button, index)
    undoButton.isHidden = false
    Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(hideUndoButton), userInfo: nil, repeats: false)
    footerStackView.removeArrangedSubview(button)
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
  
  func createTabButton(_ webVC: WebViewController) -> TabButton? {
//    guard let index = viewControllers.indexOf(webVC) else {
//      return nil
//    }
    
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
    
    let leftScreenEdgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgePanGesture(_:)))
    leftScreenEdgePanGesture.edges = UIRectEdge.left
    view.addGestureRecognizer(leftScreenEdgePanGesture)
    
    let rightScreenEdgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleScreenEdgePanGesture(_:)))
    rightScreenEdgePanGesture.edges = UIRectEdge.right
    view.addGestureRecognizer(rightScreenEdgePanGesture)
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
  
  func addTabButton(_ button: UIView, index: Int? = nil) {
    if let index = index {
      footerStackView.insertArrangedSubview(button, at: index)
      return
    }
    
    footerStackView.addArrangedSubview(button)
//    footerScrollView.contentSize = CGSize(width: footerStackView.frame.width, height: footerStackView.frame.height)
    let x = footerScrollView.contentSize.width + button.bounds.width - footerScrollView.bounds.width
    if x > 0 {
      footerScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
  }
  
  func createAndAddTabButtonToFooter(_ webVC: WebViewController) {
    let button = createTabButton(webVC)
    addTabButton(button!)
  }
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
      return false
    }
    
    let vel = pan.velocity(in: view)
    return abs(vel.y) > abs(vel.x)
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
      let point = gesture.translation(in: view)
      let frame = button.frame.offsetBy(dx: point.x, dy: point.y)
      button.frame = frame
      gesture.setTranslation(CGPoint.zero, in: view)
    case .ended:
      if button.frame.maxY < 0 {
        removeWebView(webVC, button: button)
      } else {
        button.frame = originalFrame
      }
    default:
      break
    }
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
  
  @objc func reloadPage(_ gesture: UIGestureRecognizer) {
    guard let button = gesture.view as? TabButton else {
      return
    }
    button.webVC?.reloadPage()
  }
  
  @objc func updateCurrentWebView(_ gesture: UIGestureRecognizer) {
    guard let button = gesture.view as? TabButton else {
      return
    }
    hideCurrentWebView()
    updateWebView(button.webVC!)
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

