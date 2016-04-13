//
//  BoardViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/22/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit
enum BoardMode: Int {
    case ID = 0
    case GList = 1
    case Web = 2
    case MList = 3
    case Recycle = 4
    case Trash = 5
    case SameThread = 6
}
class BoardViewController: BaseTableViewController {
    var boardName: String?
    var mode: BoardMode = .Web
    
    var board: Board?
    var content: [Article] = []
    
    let ids = (cellID: "cell", loading: "loading")
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Loading..."
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "LoadingCell", bundle: nil), forCellReuseIdentifier: ids.loading)
        tableView.registerNib(UINib(nibName: "BoardCell", bundle: nil), forCellReuseIdentifier: ids.cellID)
        loadData()
    }
    
    var isLoading = false
    var isLoaded = false
    let perPage = 30
    var page = 1
    var loadingCell: LoadingCell?
    private func loadData() {
        guard !isLoading else { return }
        guard let boardName = boardName else { return }
        isLoading = true
        API.Board(name: boardName, mode: mode, perPage: perPage, page: page).handleResponse { [weak self] (_, _, d, e) -> () in
            guard let this = self else { return }
            guard let data = d else {
                this.clearStatus()
                po(e?.localizedDescription)
                return
            }
            this.board = Board(data: data)
            this.display()
        }
    }
    
    private func display() {
        renewPageInfo()
        title = board?.desc ?? board?.name ?? "版  面"
        content += board?.articles ?? []
        clearStatus()
        tableView.reloadData()
    }
    
    private func clearStatus() {
        loadingCell?.stop()
        refreshControl?.endRefreshing()
        isLoading = false
    }
    
    private func renewPageInfo() {
        guard let board = self.board, p = board.pagination, cp = p.currentPage, ap = p.pageCount else {
            return
        }
        if cp == ap {
            isLoaded = true
        } else {
            isLoaded = false
            page = cp + 1
        }
    }
    
    private func addToFavorite() {
        guard let board = board, name = board.name else { return }
        let level = 0
        API.AddToFavorite(level: level, name: name, dir: 0).handleResponse { (_, _, data, e) in
            guard let data = data else {
                // FIXME: add error handler
                print(e)
                return
            }
            let fav = Favorite(data: data)
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.NewFavoriteAdded, object: nil, userInfo: [Keys.FavoriteLevel: level, Keys.FavoriteInfo: fav])
            po("版面收藏成功")
        }
    }
    
    @objc @IBAction private func onRefresh(sender: UIRefreshControl) {
        page = 1
        content = []
        loadData()
    }
    
    @objc @IBAction private func onAction(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "更多操作", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "查看版面信息", style: UIAlertActionStyle.Default, handler: { (_) -> Void in
            po("info")
        }))
        // TODO: If board is already added. what to do
        alert.addAction(UIAlertAction(title: "收藏版面", style: UIAlertActionStyle.Default, handler: { [weak self] (_) -> Void in
            // for now, just support add to top level in favorite.
            self?.addToFavorite()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @objc @IBAction private func onCompose(sender: UIBarButtonItem) {
        po("compose")
        presentCompose(nil, boardName: board?.name) { [weak self] isCancel, article, error in
            guard let this = self else { return }
            this.dismissViewControllerAnimated(true, completion: nil)
            if let _ = article {
                this.page = 1
                this.content = []
                this.loadData()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return content.count > 0 ? 1 : 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count + (isLoaded ? 0 : 1)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard indexPath.row < content.count else {
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
        let cell = tableView.dequeueReusableCellWithIdentifier(ids.cellID, forIndexPath: indexPath) as! BoardCell
        cell.update(content[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard indexPath.row < content.count else { return }
        let data = content[indexPath.row]
        navigateToThread(data)
    }
}
