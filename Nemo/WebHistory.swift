//
//  WebHistory.swift
//  Nemo
//
//  Created by Dushyant Bansal on 04/09/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import Foundation

class WebHistory {
  static var defaultHistory = WebHistory()
  var URLs: [String: Int]
  
  init() {
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true)[0]
    let url = NSURL(fileURLWithPath: paths).URLByAppendingPathComponent("data.data")
    guard let path = url.path where NSFileManager.defaultManager().fileExistsAtPath(path) else {
      URLs = [:]
      return
    }
    
    if let data = NSData(contentsOfFile: path),
      urls = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: Int] {
      
      print("web history backup file loaded")
      URLs = urls!
    } else {
      URLs = [:]
    }
  }
  
  func addURL(url: NSURL) {
    var newCount = 1
    if let count = URLs[url.absoluteString] {
      newCount += count
    }
    
    URLs.updateValue(newCount, forKey: url.absoluteString)
    save()
  }
  
  func save() {
    print(URLs)
    let data: NSData
    do {
      data = try NSJSONSerialization.dataWithJSONObject(self.URLs, options: .PrettyPrinted)
    } catch let error {
      print(error)
      return
    }
    
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true)[0]
    let url = NSURL(fileURLWithPath: paths).URLByAppendingPathComponent("data.data")
    guard let path = url.path else {
      return
    }
    
    if (!NSFileManager.defaultManager().fileExistsAtPath(path)) {
      NSFileManager.defaultManager().createFileAtPath(path, contents: data, attributes: nil)
      print("web history backup file created")
    } else {
      do {
        try data.writeToFile(path, options: .DataWritingFileProtectionNone)
        print("web history backup file updated")
      } catch let error {
        print(error)
      }
    }
    
  }
  
  func searchForText(text: String) -> [NSURL] {
    return URLs.filter { url -> Bool in
      return (url.0.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil)
    }.sort({ (url1, url2) -> Bool in
      return url1.1 > url2.1
    }).map({ (url) -> NSURL in
      return NSURL(string: url.0)!
    })
  }
}
