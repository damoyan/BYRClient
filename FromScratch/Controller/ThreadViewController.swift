//
//  ThreadViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/23/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit
import SwiftyJSON

class ThreadViewController: BaseTableViewController {
    
    var topic: Article?
    var content = [Article]()
    
    let ids = (cell: "cell", header: "header", loading: "loading")
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: ids.cell)
        tableView.registerNib(UINib(nibName: "LoadingCell", bundle: nil), forCellReuseIdentifier: ids.loading)
        tableView.registerNib(UINib(nibName: "ArticleHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ids.header)
        title = topic?.title
        loadData()
    }
    
    var isLoading = false
    var isLoaded = false
    let perPage = 20
    var page = 1
    private func loadData() {
        guard !isLoading else { return }
        guard let name = topic?.boardName, id = topic?.groupID ?? topic?.id else { return }
        isLoading = true
        API.Thread(name: name, id: id, uid: nil, perPage: perPage, page: page).handleResponse { [weak self] (_, _, d, e) -> () in
            guard let this = self else { return }
            guard let data = d else {
                this.clearStatus()
                print(e?.localizedDescription)
                return
            }
            this.topic = Article(data: data)
            this.display()
        }
    }
    
    private func display() {
        clearStatus()
        title = topic?.title
        content += topic?.replys ?? []
        tableView.reloadData()
    }
    
    private func clearStatus() {
        isLoading = false
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return content.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ArticleCell.calculateHeight(content[indexPath.section], boundingWidth: tableView.bounds.width)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ids.cell, forIndexPath: indexPath) as! ArticleCell
        let data = content[indexPath.section]
        cell.label.text = data.content
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(ids.header) as! ArticleHeader
        let data = content[section]
        view.update(data)
        return view
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
