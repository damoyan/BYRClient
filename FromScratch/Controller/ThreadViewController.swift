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
    var titleLabel: UILabel?
    weak var refresh: RefreshView?
    
    let ids = (cell: "cell", header: "header", loading: "loading")
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
        let re = RefreshView(size: CGSize(width: tableView.frame.width, height: 30)) { [weak self] () -> () in
            self?.loadData()
        }
        refresh = re
        tableView.addSubview(re)
        tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: ids.cell)
        tableView.registerNib(UINib(nibName: "LoadingCell", bundle: nil), forCellReuseIdentifier: ids.loading)
        tableView.registerNib(UINib(nibName: "ArticleHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: ids.header)
        setTitleLabelText("Loading...")
        loadData()
    }
    
    private func setupTitle() {
        if let bar = navigationController?.navigationBar {
            let h = bar.frame.height
            let w = bar.frame.width - 80 * 2
            let view = UIView()
            view.frame = CGRect(origin: CGPointZero, size: CGSize(width: w, height: h))
            let label = UILabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: w, height: h)))
            view.addSubview(label)
//            po("label.frame", label.frame)
            label.textColor = UIColor.whiteColor()
            label.numberOfLines = 0
            label.font = UIFont.systemFontOfSize(18)
            label.textAlignment = .Center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            titleLabel = label
            self.navigationItem.titleView = view
        }
    }
    
    private func setTitleLabelText(title: String?) {
        titleLabel?.text = title
    }
    
    var isLoading = false
    var isLoaded = false
    let perPage = 20
    var page = 1
    var loadingCell: LoadingCell?
    func loadData() {
        guard !isLoading else { return }
        guard let name = topic?.boardName, id = topic?.id ?? topic?.replyID ?? topic?.groupID else { return }
        isLoading = true
        API.Thread(name: name, id: id, uid: nil, perPage: perPage, page: page).handleResponse { [weak self] (_, _, d, e) -> () in
            guard let this = self else { return }
            guard let data = d else {
                this.clearStatus()
                po(e?.localizedDescription)
                return
            }
            this.topic = Article(data: data)
            this.display()
        }
    }
    
    private func display() {
        setTitleLabelText(topic?.title)
        guard let replys = topic?.replys where replys.count > 0 else {
            clearStatus()
            return
        }
        let before = (page - 1) * perPage
        let currentPageCount = content.count - before
        assert(currentPageCount >= 0, "before should less than content.count")
        if currentPageCount >= replys.count {
            clearStatus()
            return
        } else {
            let new = replys[currentPageCount..<replys.count].map { article -> ArticleCellData in
                let ar = ArticleCellData(article: article)
                ar.delegate = self
                return ar
            }
            clearStatus()
            tableView.beginUpdates()
            let count = content.count
            content += new
            tableView.insertSections(NSIndexSet(indexesInRange: NSMakeRange(count, new.count)), withRowAnimation: .Fade)
            tableView.endUpdates()
        }
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
        refresh?.endRefreshing()
        refreshControl?.endRefreshing()
        isLoading = false
        renewPageInfo()
    }
    
    @objc @IBAction private func actionRefresh(sender: UIRefreshControl) {
        page = 1
//        content = []
        loadData()
    }
    
    @objc @IBAction private func actionShare(sender: UIBarButtonItem) {
        po("share")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return content.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 //+ ((section == content.count - 1) ? (isLoaded ? 0 : 1) : 0)
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
            po("load more")
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
        view.threadVC = self
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
        po("thread deinit")
    }
}

extension ThreadViewController {
    func presentUserProfile(id: String, sender: AnyObject) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("vcUserProfile") as! UserProfileViewController
        vc.modalPresentationStyle = .Popover
        vc.userId = id
        if let pvc = vc.popoverPresentationController {
            if let view = sender as? UIView {
                pvc.sourceView = view
                pvc.sourceRect = view.bounds
            } else if let item = sender as? UIBarButtonItem {
                pvc.barButtonItem = item
            }
            pvc.delegate = self
        }
        presentViewController(vc, animated: true, completion: nil)
    }
}

extension ThreadViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}
