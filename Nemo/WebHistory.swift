//
//  WebHistory.swift
//  Nemo
//
//  Created by Dushyant Bansal on 04/09/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class WebHistory {
  static var defaultHistory = WebHistory()
  var URLs: [String: Int]
  let pathComponent: String
  
  init(_ pathComponent: String = "data.data") {
    self.pathComponent = pathComponent
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)[0]
    let url = URL(fileURLWithPath: paths).appendingPathComponent(pathComponent)
    let path = url.path
    guard FileManager.default.fileExists(atPath: path) else {
      URLs = [:]
      return
    }
    
    if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
      let urls = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Int] {
      
      print("web history backup file loaded")
      URLs = urls!
    } else {
      URLs = [:]
    }
  }
  
  func addURL(_ url: URL) {
    var newCount = 1
    var urlc = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    urlc.query = nil
    let sanitizedURLString = urlc.string!

    if let count = URLs[sanitizedURLString] {
      newCount += count
    }
    
    URLs.updateValue(newCount, forKey: sanitizedURLString)
    save()
  }
  
  fileprivate func save() {
    print(URLs)
    let data: Data
    do {
      data = try JSONSerialization.data(withJSONObject: self.URLs, options: .prettyPrinted)
    } catch let error {
      print(error)
      return
    }
    
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)[0]
    let url = URL(fileURLWithPath: paths).appendingPathComponent(pathComponent)
    let path = url.path    
    if (!FileManager.default.fileExists(atPath: path)) {
      FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
      print("web history backup file created")
    } else {
      do {
        try data.write(to: URL(fileURLWithPath: path), options: .noFileProtection)
        print("web history backup file updated")
      } catch let error {
        print(error)
      }
    }
  }
  
  fileprivate func cleanURL(_ url: String) -> String {
//TODO:
//    let url = NSURL(string: url)!
//    return url.host! + url.path!
    return url.components(separatedBy: ":").last!
  }
  
  func searchForText(_ text: String) -> [URL] {
    return URLs.filter { url -> Bool in
      return (cleanURL(url.0).range(of: text, options: NSString.CompareOptions.caseInsensitive) != nil)
    }.sorted(by: { (url1, url2) -> Bool in
      let r1 = cleanURL(url1.0).range(of: text, options: NSString.CompareOptions.caseInsensitive)?.lowerBound
      let r2 = cleanURL(url2.0).range(of: text, options: NSString.CompareOptions.caseInsensitive)?.lowerBound
      if (r1 == r2) {
        return url1.1 > url2.1
      } else {
      return r1 < r2
      }
    }).map({ (url) -> URL in
      return URL(string: url.0)!
    })
  }
}
