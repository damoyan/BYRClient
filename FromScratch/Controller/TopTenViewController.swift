//
//  TopTenViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/22/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit
import SwiftyJSON

class TopTenViewController: BaseTableViewController {

    var content: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.registerNib(UINib(nibName: "BoardCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView()
        loadData()
    }
    
    var isLoading = false
    private func loadData() {
        guard !isLoading else { return }
        isLoading = true
        API.TopTen.handleResponse { [weak self] (_, _, d, e) -> () in
            guard let this = self else { return }
            guard let data = d?["article"].array else {
                print(e?.localizedDescription)
                return
            }
            this.content = data.map { Article(data: $0) }
            this.tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    let cellID = "cell"
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! BoardCell
        cell.update(content[indexPath.row], isTopTen: true)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let data = content[indexPath.row]
        navigateToThread(data)
    }
}
