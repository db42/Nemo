//
//  WebController.swift
//  Nemo
//
//  Created by Dushyant Bansal on 08/07/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UITextFieldDelegate, UIWebViewDelegate {

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var webView: UIWebView!
  weak var delegate: MainVCWebDelegate?
  var url: NSURL?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    webView.delegate = self
    textField.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if let text = textField.text where text != "" {
      return
    }
    
    if let url = self.url {
      webView.loadRequest(NSURLRequest(URL: url))
      textField.text = url.absoluteString
    } else {
      textField.becomeFirstResponder()
    }
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    guard let text = textField.text else {
      return true
    }
    
    textField.resignFirstResponder()
    
    let str = text.hasPrefix("http") ? text : "http://\(text)"
    
    if let url = NSURL(string: str) {
      webView.loadRequest(NSURLRequest(URL: url))
    } else {
      let txt = "https://www.google.com/search?q=\(text)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
      webView.loadRequest(NSURLRequest(URL: NSURL(string: txt!)!))
    }
    return true
  }
  
  func reloadPage() {
    webView.reload()
  }
  
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    if let string:NSString = request.URL?.absoluteString where string.hasPrefix("newtab:") {
      if let url = NSURL(string: string.substringFromIndex(7)) {
        self.delegate?.webVC(self, shouldOpenNewTabForURL: url)
        return false
      }
    }
    return true
  }
  

  func webViewDidFinishLoad(webView: UIWebView) {
    // JS Injection hack to solve the target="_blank" issue and open a real browser in such case.
    let JSInjection = "javascript: var allLinks = document.getElementsByTagName('a'); if (allLinks) {var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target'); if (target && target == '_blank') {link.setAttribute('target','_self');link.href = 'newtab:'+link.href;}}}"
    webView.stringByEvaluatingJavaScriptFromString(JSInjection)
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      guard let host = webView.request?.URL?.host else {
        return
      }
      let urlString = "http://\(host)/favicon.ico"
      let ur = NSURL(string: urlString)!
      if let data = NSData(contentsOfURL: ur),
        image = UIImage(data: data) {
          print(ur)
          self.delegate?.webVC(self, faviconDidLoad: image)
      }
    }
  }
}
