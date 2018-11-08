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

class WebViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {

  var currentOffset: CGFloat = 0.0
  @IBOutlet weak var searchView: UIView!
  @IBOutlet weak var searchTextField: UITextField!
  
  @IBOutlet weak var searchResultsTableView: UITableView!
  @IBOutlet weak var webView: NemoWebView!
  weak var delegate: MainVCWebDelegate?
  weak var tabButton: TabButton?
  
  @IBOutlet weak var searchViewHeightConstraint: NSLayoutConstraint!
  var url: URL?
  var searchResults: [URL] = []
  
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
    webView.scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)

    searchResultsTableView.dataSource = self
    searchResultsTableView.delegate = self
    
    let hideKeyboardGesture = UIGestureRecognizer()
    hideKeyboardGesture.delegate = self
    webView.addGestureRecognizer(hideKeyboardGesture)
  }

  fileprivate func hideSearchResultsTableView() {
    searchResultsTableView.isHidden = true
  }
  
  // MARK: SearchResultsDelegate
  func didSelectURL(_ url: URL) {
    searchTextField.text = url.absoluteString
    searchTextField.resignFirstResponder()
    hideSearchResultsTableView()
    webView.loadRequest(URLRequest(url: url))
    tabButton?.isLoading = true
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//    textField.resignFirstResponder()
    return false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if let text = searchTextField.text, text != "" {
      return
    }
    
    if let url = self.url {
      webView.loadRequest(URLRequest(url: url))
      searchTextField.text = url.absoluteString
    } else {
      searchTextField.becomeFirstResponder()
    }
  }
  
  func reloadPage() {
    webView.reload()
  }
  
  func reset() { //Incomplete
    //reset URL
    //reset tab button
    self.url = nil
//    webView.
  }
  
  fileprivate func openWebPageForUserText(_ text: String) {
    let str = text.hasPrefix("http") ? text : "http://\(text)"
    
    if let url = URL(string: str), url.absoluteString.range(of: ".") != nil {
      webView.loadRequest(URLRequest(url: url))
    } else {
      let txt = "https://www.google.com/search?q=\(text)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
      webView.loadRequest(URLRequest(url: URL(string: txt!)!))
    }
  }
  
  // MARK: - UIWebViewDelegate
  func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
    if let string: NSString = request.url?.absoluteString as? NSString, string.hasPrefix("newtab:") {// () -> Bool in
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
      searchTextField.text = url.absoluteString
    }
    // JS Injection hack to solve the target="_blank" issue and open a real browser in such case.
    let JSInjection = "javascript: var allLinks = document.getElementsByTagName('a'); if (allLinks) {var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target'); if (target && target == '_blank') {link.setAttribute('target','_self');link.href = 'newtab:'+link.href;}}}"
    webView.stringByEvaluatingJavaScript(from: JSInjection)
    
    DispatchQueue.global().async {
      guard let host = webView.request?.url?.host else {
        return
      }
      let urlString = "http://\(host)/favicon.ico"
      let ur = URL(string: urlString)!
      if let data = try? Data(contentsOf: ur),
        let image = UIImage(data: data) {
          self.tabButton?.isLoading = false
          print(ur)
          self.delegate?.webVC(self, faviconDidLoad: image)
      }
    }
  }
  
  func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    self.tabButton?.isLoading = false
  }
  
  func webViewDidStartLoad(_ webView: UIWebView) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  
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
    
    openWebPageForUserText(text)
  }
  
  //MARK: - UIScrollViewDelegate
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    currentOffset = scrollView.contentOffset.y
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let scrollPos = scrollView.contentOffset.y
    if scrollPos > currentOffset {
      UIView.animate(withDuration: 0.25, animations: {
        self.searchView.isHidden = true
        self.searchViewHeightConstraint.constant = 0
        self.delegate?.hideTabBarFooter()
      })
    } else {
      searchView.isHidden = false
      searchViewHeightConstraint.constant = 44
      delegate?.showTabBarFooter()
    }
  }
  
  @IBAction func handleTextFieldEdit(_ sender: UITextField) {
    guard let text = sender.text else {
      return
    }
    //show table view
    searchResultsTableView.isHidden = false
    
    //update and reload table view data
    updateSearchResults(for: text)
    searchResultsTableView.reloadData()
  }
}

extension WebViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.selectAll(nil)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if let text = textField.text {
      openWebPageForUserText(text)
    }
    
    hideSearchResultsTableView()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

extension WebViewController: UITableViewDataSource, UITableViewDelegate {
  
  func updateSearchResults(for text: String) {
    searchResults = WebHistory.defaultHistory.searchForText(text)
  }
  
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
    if (cell == nil) {
      cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
    }
    let url = searchResults[indexPath.row]
    cell!.textLabel?.text = url.host! + url.path
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.row < searchResults.count else {
      return
    }
    
    let url = searchResults[indexPath.row]
    didSelectURL(url)
  }
}
