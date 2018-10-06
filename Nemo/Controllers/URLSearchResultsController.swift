//
//  URLSearchResultsController.swift
//  Nemo
//
//  Created by Dushyant Bansal on 03/09/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit

class URLSearchResultsController: UITableViewController, UISearchResultsUpdating {
  
  var searchResults: [URL]!
  weak var delegate: SearchResultsDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchResults = []
  }

  func updateSearchResults(for searchController: UISearchController) {
    if let text = searchController.searchBar.text {
      searchResults = WebHistory.defaultHistory.searchForText(text)
      tableView.reloadData()
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
    if (cell == nil) {
      cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
    }
    let url = searchResults[indexPath.row]
    cell!.textLabel?.text = url.host! + url.path
    return cell!
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.row < searchResults.count else {
      return
    }
    
    let url = searchResults[indexPath.row]
    delegate?.didSelectURL(url)
  }
}
