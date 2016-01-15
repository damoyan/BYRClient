//
//  ThreadViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/23/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit
import SwiftyJSON

class ThreadViewController: BaseTableViewController, ArticleCellDataDelegate {
    
    var topic: Article?
    var content = [ArticleCellData]()
    
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
    var loadingCell: LoadingCell?
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
        renewPageInfo()
        title = topic?.title
        content += (topic?.replys ?? []).map {
            let ar = ArticleCellData(article: $0)
            ar.delegate = self
            return ar
        }
        clearStatus()
        tableView.reloadData()
    }
    
    private func renewPageInfo() {
        guard let topic = self.topic, p = topic.pagination, cp = p.currentPage, ap = p.pageCount else {
            return
        }
        if cp == ap {
            isLoaded = true
        } else {
            isLoaded = false
            page = cp + 1
        }
    }
    
    private func clearStatus() {
        loadingCell?.stop()
        refreshControl?.endRefreshing()
        isLoading = false
    }
    
    @objc @IBAction private func actionRefresh(sender: UIRefreshControl) {
        page = 1
        content = []
        loadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return content.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + ((section == content.count - 1) ? (isLoaded ? 0 : 1) : 0)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 44 // loading Cell
        }
        return ArticleCell.calculateHeight(content[indexPath.section], boundingWidth: tableView.bounds.width)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard indexPath.row == 0 else {
            var cell: LoadingCell
            if let c = loadingCell {
                cell = c
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier(ids.loading, forIndexPath: indexPath) as! LoadingCell
                loadingCell = cell
            }
            cell.spin()
            loadData()
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(ids.cell, forIndexPath: indexPath) as! ArticleCell
        let data = content[indexPath.section]
        cell.update(data)
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
    
    func dataDidChanged(data: ArticleCellData) {
        data.contentHeight = nil
        content.enumerate().filter { (index, d) -> Bool in
            d === data
        }.forEach { (index, d) -> () in
            var isVisible = false
            if let visibles = tableView.indexPathsForVisibleRows {
                for ip in visibles {
                    if ip.section == index {
                        isVisible = true
                        break
                    }
                }
            }
            if isVisible {
                tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    deinit {
        content.removeAll()
        print("thread deinit")
    }
}
