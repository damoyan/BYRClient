//
//  FavoriteViewController.swift
//  FromScratch
//
//  Created by Yu Pengyang on 12/21/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class FavoriteViewController: BaseTableViewController {

    var level: Int = 0
    var content: [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: observe favorite changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.favoriteAdded(_:)), name: Notifications.NewFavoriteAdded, object: nil)
        loadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    var isLoading = false
    private func loadData() {
        if isLoading {
            po("is loading")
            return
        }
        isLoading = true
        API.Favorite(level: level).handleResponse { [weak self] (_, _, d, e) -> () in
            guard let data = d else {
                po(e?.localizedDescription)
                self?.isLoading = false
                return
            }
            self?.display(Favorite(data: data))
            self?.isLoading = false
        }
    }
    
    private func display(favorite: Favorite) {
        content.removeAll(keepCapacity: false)
        if let subs = favorite.subFavorites {
            content += subs as [AnyObject]
        }
        if let ss = favorite.sections {
            content += ss as [AnyObject]
        }
        if let bs = favorite.boards {
            content += bs as [AnyObject]
        }
        tableView.reloadData()
    }
    
    private func deleteFavorite(name: String, dir: Int) {
        // TODO: add delete confirm alert
        API.DeleteFavorite(level: self.level, name: name, dir: dir).handleResponse { [weak self] (_, _, d, e) in
            guard let data = d else {
                po("delete error: \(e)")
                return
            }
            po("delete success: name - \(name), dir - \(dir)")
            guard let this = self else { return }
            this.display(Favorite(data: data))
        }
    }
    
    // MARK: Notifications
    @objc private func favoriteAdded(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let level = userInfo[Keys.FavoriteLevel] as? Int, fav = userInfo[Keys.FavoriteInfo] as? Favorite else {
            return
        }
        if level == self.level {
            display(fav)
        }
    }
    
    
    // MARK: TableView DataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    let cellID = "cell"
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellID)
        }
        let data = content[indexPath.row]
        switch data {
        case let sub as Favorite:
            cell?.textLabel?.text = sub.desc
            cell?.detailTextLabel?.text = "[目录]"
        case let sec as Section:
            cell?.textLabel?.text = sec.desc ?? sec.name
            cell?.detailTextLabel?.text = "[分区]"
        case let b as Board:
            cell?.textLabel?.text = b.desc ?? b.name
            cell?.detailTextLabel?.text = nil
        default:
            break
        }
        cell?.accessoryType = .DisclosureIndicator
        cell?.detailTextLabel?.textColor = AppSharedInfo.sharedInstance.currentTheme.BoardNaviCellSubtitleColor
        return cell!
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Insert:
            break
        case .Delete:
            let data = content[indexPath.row]
            switch data {
            case let sub as Favorite:
                if let name = sub.desc {
                    deleteFavorite(name, dir: 1)
                }
            case let sec as Section:
                if let name = sec.name {
                    deleteFavorite(name, dir: 0)
                }
            case let b as Board:
                if let name = b.name {
                    deleteFavorite(name, dir: 0)
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    // MARK: TableView Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let data = content[indexPath.row]
        switch data {
        case let sub as Favorite:
            if let level = sub.level {
                navigateToFavorite(level)
            }
        case let sec as Section:
            navigateToSectionDetail(sec)
        case let b as Board:
            if let name = b.name {
                navigateToBoard(name)
            }
        default:
            break
        }
    }
}
