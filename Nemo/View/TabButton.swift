//
//  TabButton.swift
//  Nemo
//
//  Created by Dushyant Bansal on 13/07/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit


class TabButton: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
  weak var webVC: WebViewController?
  weak var indicator: UIActivityIndicatorView?
  weak var iconView: UIImageView?
  
  var isLoading: Bool = false {
    didSet {
      OperationQueue.main.addOperation {
        if self.isLoading {
          self.iconView?.isHidden = true
          
          if self.indicator == nil {
            let indicator = UIActivityIndicatorView(style: .gray)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            
            indicator.hidesWhenStopped = true
            self.addSubview(indicator)
            
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.indicator = indicator
          }
          
          self.indicator?.startAnimating()
        } else {
          self.iconView?.isHidden = false
          self.indicator?.stopAnimating()
          self.indicator?.isHidden = true
        }
      }
    }
  }
  
  convenience init() {
    self.init(frame: CGRect(x: 0,y: 0,width: 44,height: 44))
    self.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
    self.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
    let image = UIImageView(frame: self.bounds.insetBy(dx: 6, dy: 4))
    
    
    image.image = UIImage(named: "favicon")
    self.layer.cornerRadius = 2.0
    self.layer.masksToBounds = true
    self.layer.borderWidth = 1
    //    tabView.backgroundColor = UIColor.whiteColor()
    self.addSubview(image)
    iconView = image
  }
  
}
