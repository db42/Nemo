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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      webView.delegate = self
      textField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    guard let text = textField.text else {
      return true
    }
    
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
  

  func webViewDidFinishLoad(webView: UIWebView) {
    let html = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.outerHTML")
    if let favicon = "".favIconUrlStringFromHtmlString(html) {
      print(" fav: \(favicon)")
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      guard let host = webView.request?.URL?.host else {
        return
      }
      let urlString = "http://\(host)/favicon.ico"
      let ur = NSURL(string: urlString)!
      if let data = NSData(contentsOfURL: ur) {
        let image = UIImage(data: data)
        print(ur)
        self.delegate?.webVC(self, faviconDidLoad: image!)
      }
    }
    
    
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
