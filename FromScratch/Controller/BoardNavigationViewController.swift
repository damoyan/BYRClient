//
//  BoardAndFavorateViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 11/7/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class BoardNavigationViewController: UITableViewController {
    
    var ids = (section: "section", borad: "board")
    
    @IBOutlet weak var titleControl: UISegmentedControl!
    private var data: [AnyObject] = []
    
    var currentSelected: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadData()
    }
    
    private func loadData() {
        if currentSelected == 0 { // personal
            
        } else {
            API.Sections.handleResponse({ [weak self] (_, _, data, error) -> () in
                guard let strongSelf = self else {
                    return
                }
                guard let data = data else {
                    // TODO: -
                    print(error?.localizedDescription)
                    return
                }
                strongSelf.data = Section.generateArray(data["section"])
                strongSelf.display()
            })
        }
    }
    
    private func display() {
        tableView.reloadData()
    }

    @IBAction func switchTitle(sender: UISegmentedControl) {
        if currentSelected != sender.selectedSegmentIndex {
            currentSelected = sender.selectedSegmentIndex
            loadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(ids.section)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: ids.section)
        }
        cell!.textLabel?.text = (data[indexPath.row] as! Section).name
        cell!.accessoryType = .DisclosureIndicator
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
