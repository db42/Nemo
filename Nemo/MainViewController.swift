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
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let sb = UIStoryboard(name: "Main", bundle: nil)
    let webVC = sb.instantiateViewControllerWithIdentifier("WebViewController")
    webVC.view.frame = contentView.bounds
    
    addChildViewController(webVC)
    contentView.addSubview(webVC.view)
    webVC.didMoveToParentViewController(self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

