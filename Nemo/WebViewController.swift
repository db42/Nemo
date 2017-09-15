//
//  WebController.swift
//  Nemo
//
//  Created by Dushyant Bansal on 08/07/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit

class NemoWebView: UIWebView {
}

protocol SearchResultsDelegate: class {
  func didSelectURL(_ url: URL)
}

class WebViewController: UIViewController, UITextFieldDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, SearchResultsDelegate, UISearchControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate {

  var currentOffset: CGFloat = 0.0
  @IBOutlet weak var searchView: UIView!
//  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var webView: NemoWebView!
  weak var delegate: MainVCWebDelegate?
  
  @IBOutlet weak var searchViewHeightConstraint: NSLayoutConstraint!
  var searchController: UISearchController!
  var url: URL?
  
  func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    return true;
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if let change = change, keyPath == "contentOffset" {
      let oldValue = change[NSKeyValueChangeKey.oldKey] as? CGPoint
      let newValue = change[NSKeyValueChangeKey.newKey] as? CGPoint
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    webView.delegate = self
    webView.scrollView.scrollsToTop = true
    webView.scrollView.delegate = self
//    textField.delegate = self
    webView.scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)

    
    let hideKeyboardGesture = UIGestureRecognizer()
    hideKeyboardGesture.delegate = self
    webView.addGestureRecognizer(hideKeyboardGesture)
    
    let sb = UIStoryboard(name: "Main", bundle: nil)
    let srController = sb.instantiateViewController(withIdentifier: "URLSearchResultsController") as! URLSearchResultsController
    srController.delegate = self
    searchController = UISearchController(searchResultsController: srController)
    searchController.searchBar.frame = searchView.bounds
    searchController.searchResultsUpdater = srController
    searchController.delegate = self
    searchController.searchBar.delegate = self
    
//    searchView.layoutMargins = UIEdgeInsetsZero
    searchView.addSubview(searchController.searchBar)
//    let views = ["searchBar": searchController.searchBar]
//    let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[searchBar]-|", options: .AlignAllCenterX, metrics: nil, views: views)
//    let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[searchBar]-|", options: .AlignAllCenterY, metrics: nil, views: views)
//    searchView.addConstraints(hConstraints)
//    searchView.addConstraints(vConstraints)
    searchController.searchBar.autoresizingMask = UIViewAutoresizing.flexibleWidth
//    searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
    
    searchController.searchBar.returnKeyType = UIReturnKeyType.go
    searchController.searchBar.autocapitalizationType = UITextAutocapitalizationType.none
    searchView.bringSubview(toFront: searchController.searchBar)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    searchController.searchBar.subviews[0].subviews[0].frame = searchView.bounds
  }
  
  //MARK: SearchControllerDelegate
  func didDismissSearchController(_ searchController: UISearchController) {
    searchController.searchBar.text = webView.request?.url?.absoluteString
  }
  
  // MARK: SearchResultsDelegate
  func didSelectURL(_ url: URL) {
    searchController.searchBar.text = url.absoluteString
    self.dismiss(animated: true, completion: nil)
    webView.loadRequest(URLRequest(url: url))
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//    textField.resignFirstResponder()
    return false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if let text = searchController.searchBar.text, text != "" {
      return
    }
    
    if let url = self.url {
      webView.loadRequest(URLRequest(url: url))
      searchController.searchBar.text = url.absoluteString
    } else {
      searchController.searchBar.becomeFirstResponder()
    }
  }
  
  func reloadPage() {
    webView.reload()
  }
  
  // MARK: - UIWebViewDelegate
  func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    if let string: NSString = request.url?.absoluteString as! NSString, string.hasPrefix("newtab:") {// () -> Bool in
      if let url = URL(string: string.substring(from: 7)) {
        self.delegate?.webVC(self, shouldOpenNewTabForURL: url)
        return false
      }
    }
    return true
  }
  

  func webViewDidFinishLoad(_ webView: UIWebView) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
    
    if let url = webView.request?.url {
      WebHistory.defaultHistory.addURL(url)
      searchController.searchBar.text = url.absoluteString
    }
    // JS Injection hack to solve the target="_blank" issue and open a real browser in such case.
    let JSInjection = "javascript: var allLinks = document.getElementsByTagName('a'); if (allLinks) {var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target'); if (target && target == '_blank') {link.setAttribute('target','_self');link.href = 'newtab:'+link.href;}}}"
    webView.stringByEvaluatingJavaScript(from: JSInjection)
    
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
      guard let host = webView.request?.url?.host else {
        return
      }
      let urlString = "http://\(host)/favicon.ico"
      let ur = URL(string: urlString)!
      if let data = try? Data(contentsOf: ur),
        let image = UIImage(data: data) {
          print(ur)
          self.delegate?.webVC(self, faviconDidLoad: image)
      }
    }
  }
  
  func webViewDidStartLoad(_ webView: UIWebView) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
  
  //MARK: textField Delegate
  
//  func textFieldDidBeginEditing(textField: UITextField) {
//    if textField.text != "" {
//      textField.selectAll(nil)
//    }
//  }
//  
//  func textFieldShouldReturn(textField: UITextField) -> Bool {
//    return true
//  }
  
  // MARK: search bar delegate
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    if let textField = searchBar.value(forKey: "_searchField") as? UITextField {
      textField.selectAll(nil)
    }
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    dismiss(animated: true, completion: nil)
    guard let text = searchBar.text else {
      return
    }
    
    let str = text.hasPrefix("http") ? text : "http://\(text)"
    
    if let url = URL(string: str), url.absoluteString.range(of: ".") != nil {
      webView.loadRequest(URLRequest(url: url))
    } else {
      let txt = "https://www.google.com/search?q=\(text)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
      webView.loadRequest(URLRequest(url: URL(string: txt!)!))
    }
  }
  
  //MARK: - UIScrollViewDelegate
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    currentOffset = scrollView.contentOffset.y
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let scrollPos = scrollView.contentOffset.y
    if scrollPos > currentOffset {
      UIView.animate(withDuration: 0.25, animations: {
        self.searchViewHeightConstraint.constant = 0
        self.delegate?.hideTabBarFooter()
      })
    } else {
      searchViewHeightConstraint.constant = 44
      delegate?.showTabBarFooter()
    }
  }
  
}
