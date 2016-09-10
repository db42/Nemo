//
//  URLSearchResultsController.swift
//  Nemo
//
//  Created by Dushyant Bansal on 03/09/16.
//  Copyright © 2016 Dushyant Bansal. All rights reserved.
//

import UIKit

class URLSearchResultsController: UITableViewController, UISearchResultsUpdating {
  
  var searchResults: [NSURL]!
  weak var delegate: SearchResultsDelegate?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      searchResults = []

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return searchResults.count
    }
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    if let text = searchController.searchBar.text {
      searchResults = WebHistory.defaultHistory.searchForText(text)
      tableView.reloadData()
    }
  }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier")
      if (cell == nil) {
        cell = UITableViewCell(style: .Default, reuseIdentifier: "reuseIdentifier")
      }
      let url = searchResults[indexPath.row]
      cell!.textLabel?.text = url.host! + url.path!
      return cell!
    }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard indexPath.row < searchResults.count else {
      return
    }
    
    let url = searchResults[indexPath.row]
    delegate?.didSelectURL(url)
  }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
