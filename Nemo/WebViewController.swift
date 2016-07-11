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
    }
    return true
  }
  
  func reloadPage() {
    webView.reload()
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
